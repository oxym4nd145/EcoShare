const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const db = require('./db'); 

const app = express();
app.use(cors());
app.use(express.json());

function isNonEmptyString(value) {
    return typeof value === 'string' && value.trim() !== '';
}

async function upsertEndereco(conn, enderecoId, enderecoData) {
    const { cep, logradouro, numero, complemento, bairro, cidade, estado } = enderecoData;
    const hasEnderecoPayload = [cep, logradouro, bairro, cidade, estado, numero, complemento]
        .some((value) => value !== undefined);

    if (!hasEnderecoPayload) return enderecoId || null;

    if (!enderecoId) {
        if (!isNonEmptyString(cep) || !isNonEmptyString(logradouro) || !isNonEmptyString(bairro) || !isNonEmptyString(cidade) || !isNonEmptyString(estado)) {
            throw new Error('Dados de endereço incompletos');
        }

        const [result] = await conn.execute(
            'INSERT INTO Endereco (cep, logradouro, numero, complemento, bairro, cidade, estado) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [cep, logradouro, numero || null, complemento || null, bairro, cidade, estado]
        );

        return result.insertId;
    }

    const [rows] = await conn.execute('SELECT * FROM Endereco WHERE id_endereco = ?', [enderecoId]);
    if (rows.length === 0) {
        throw new Error('Endereço não encontrado');
    }

    const atual = rows[0];
    const novoEndereco = {
        cep: isNonEmptyString(cep) ? cep : atual.cep,
        logradouro: isNonEmptyString(logradouro) ? logradouro : atual.logradouro,
        numero: numero !== undefined ? numero : atual.numero,
        complemento: complemento !== undefined ? complemento : atual.complemento,
        bairro: isNonEmptyString(bairro) ? bairro : atual.bairro,
        cidade: isNonEmptyString(cidade) ? cidade : atual.cidade,
        estado: isNonEmptyString(estado) ? estado : atual.estado
    };

    await conn.execute(
        'UPDATE Endereco SET cep = ?, logradouro = ?, numero = ?, complemento = ?, bairro = ?, cidade = ?, estado = ? WHERE id_endereco = ?',
        [
            novoEndereco.cep,
            novoEndereco.logradouro,
            novoEndereco.numero,
            novoEndereco.complemento,
            novoEndereco.bairro,
            novoEndereco.cidade,
            novoEndereco.estado,
            enderecoId
        ]
    );

    return enderecoId;
}

async function inserirFoto(conn, enderecoCdn) {
    if (!isNonEmptyString(enderecoCdn)) return null;

    const [result] = await conn.execute(
        'INSERT INTO Foto (endereco_cdn) VALUES (?)',
        [enderecoCdn]
    );

    return result.insertId;
}

// Rota de Login
app.post('/api/login', async (req, res) => {
    const { email, senha } = req.body;

    if (!email || !senha) {
        return res.status(400).json({ error: 'Email e senha são obrigatórios' });
    }

    try {
        const query = 'SELECT id_usuario, nome_usuario, hash_senha FROM Usuario WHERE email = ?';

        const [rows] = await db.execute(query, [email]);

        if (rows.length === 0) {
            return res.status(401).json({ success: false, error: 'Email ou senha incorretos' });
        }

        const user = rows[0];
        const senhaOk = await bcrypt.compare(senha, user.hash_senha || '');

        if (!senhaOk) {
            return res.status(401).json({ success: false, error: 'Email ou senha incorretos' });
        }

        res.json({ 
            success: true, 
            id: user.id_usuario, 
            nome: user.nome_usuario 
        });
    } catch (error) {
        console.error("Erro no login:", error);
        res.status(500).json({ error: 'Erro interno no servidor' });
    }
});

// Rota para buscar as categorias dinâmicas
app.get('/api/categorias', async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM Categoria_tipo');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: 'Erro ao buscar categorias' });
    }
});

// Buscar Tipos de Transação
app.get('/api/transacoes', async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM Transacao_tipo');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: 'Erro ao buscar tipos de transações' });
    }
});

// Buscar Tipos de Disponibilidade
app.get('/api/disponibilidades', async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM Disponibilidade_tipo');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: 'Erro ao buscar tipos de disponibilidades' });
    }
});

// Buscar Estados de Conservação (Novo, Usado, etc.)
app.get('/api/estados', async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM Estado_tipo');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: 'Erro ao buscar estados' });
    }
});

// 1. ROTA HOME: Listar todos os itens

app.get('/api/itens', async (req, res) => {
    try {
        // Captura os novos parâmetros da URL
        const { cat, disp, est, busca } = req.query; 
        
        let query = `
            SELECT 
                i.id_item AS _id, 
                i.nome_item AS nome, 
                i.descricao, 
                cat.tipo_categoria AS categoria, 
                est.tipo_estado AS condicao, 
                disp.tipo_disponibilidade AS tipo,
                MAX(f.endereco_cdn) AS foto
            FROM Item i 
            LEFT JOIN Categoria_tipo cat ON i.categoria = cat.id_categoria 
            LEFT JOIN Estado_tipo est ON i.estado_conservacao = est.id_estado 
            LEFT JOIN Disponibilidade_tipo disp ON i.disponibilidade = disp.id_disponibilidade
            LEFT JOIN Foto_item fitem ON fitem.item_id = i.id_item
            LEFT JOIN Foto f ON fitem.foto_id = f.id_foto
            WHERE i.disponibilidade IS NOT NULL
        `;

        const params = [];

        // Filtro de Categoria
        if (cat) {
            query += ` AND i.categoria = ?`;
            params.push(cat);
        }

        // NOVO: Filtro de Disponibilidade (Transação)
        if (disp) {
            query += ` AND i.disponibilidade = ?`;
            params.push(disp);
        }

        // NOVO: Filtro de Estado de Conservação
        if (est) {
            query += ` AND i.estado_conservacao = ?`;
            params.push(est);
        }

        if (busca) {
            query += ` AND (i.nome_item LIKE ? OR i.descricao LIKE ?)`;
            params.push(`%${busca}%`, `%${busca}%`);
        }

        query += ` GROUP BY i.id_item`;

        const [rows] = await db.execute(query, params);
        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erro ao buscar itens' });
    }
});

// Rota para buscar detalhes completos de um item específico
// 1. Buscar apenas dados principais do item
app.get('/api/itens/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const query = `
            SELECT 
                i.id_item AS _id, 
                i.nome_item AS nome, 
                i.descricao AS descricao, 
                cat.tipo_categoria AS categoria, 
                disp.tipo_disponibilidade AS tipo,
                est.tipo_estado AS estado,
                u.nome_usuario AS dono,
                endr.cidade AS localizacao,
                f.endereco_cdn AS foto
            FROM Item i 
            LEFT JOIN Categoria_tipo cat ON i.categoria = cat.id_categoria 
            LEFT JOIN Disponibilidade_tipo disp ON i.disponibilidade = disp.id_disponibilidade 
            LEFT JOIN Estado_tipo est ON i.estado_conservacao = est.id_estado
            LEFT JOIN Usuario u ON i.dono_id = u.id_usuario
            LEFT JOIN Endereco endr ON u.endereco = endr.id_endereco
            LEFT JOIN Foto_item fitem ON fitem.item_id = i.id_item
            LEFT JOIN Foto f ON fitem.foto_id = f.id_foto
            WHERE i.id_item = ? 
            LIMIT 1`;

        const [rows] = await db.execute(query, [id]);
        if (rows.length === 0) return res.status(404).json({ error: 'Item não encontrado' });
        res.json(rows[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erro ao buscar item' });
    }
});

app.get('/api/usuario/:usuarioId/itens', async (req, res) => {
    try {
        // Agora o nome aqui casa com o nome na URL acima
        const { usuarioId } = req.params; 
        
        const query = `
            SELECT 
                i.id_item AS _id, 
                i.nome_item AS nome, 
                disp.tipo_disponibilidade AS tipo,
                ANY_VALUE(f.endereco_cdn) AS foto
            FROM Item i
            LEFT JOIN Disponibilidade_tipo disp ON i.disponibilidade = disp.id_disponibilidade
            LEFT JOIN Foto_item fitem ON fitem.item_id = i.id_item
            LEFT JOIN Foto f ON fitem.foto_id = f.id_foto
            WHERE i.dono_id = ?
            GROUP BY i.id_item`;

        const [rows] = await db.execute(query, [usuarioId]);
        
        // Correção do console.log (estava com vírgula em vez de ponto)
        console.log('Itens encontrados para o usuário:', usuarioId); 
        
        res.json(rows);
    } catch (error) {
        console.error("Erro na rota de itens do usuário:", error);
        res.status(500).json({ error: 'Erro ao carregar seus itens' });
    }
});

// Rota para buscar avaliações filtradas pelo ID do Item
app.get('/api/itens/:id/avaliacoes', async (req, res) => {
    try {
        const { id } = req.params;

        const queryAvaliacoes = `
            SELECT 
                a.nota, 
                a.avaliacao AS comentario, 
                t.data_transacao AS data, 
                u.nome_usuario
            FROM Avaliacao a 
            INNER JOIN Transacao t ON a.transacao_id = t.id_transacao
            INNER JOIN Usuario u ON a.avaliador_id = u.id_usuario 
            WHERE t.item_id = ?
            ORDER BY t.data_transacao DESC
        `;

        const [rows] = await db.execute(queryAvaliacoes, [id]);
        res.json(rows);
    } catch (error) {
        console.error("Erro SQL nas avaliações:", error);
        res.status(500).json({ error: 'Erro ao buscar avaliações' });
    }
});

// 3. Buscar histórico de manutenção
app.get('/api/itens/:id/manutencao', async (req, res) => {
    try {
        const { id } = req.params;
        const query = `
            SELECT data_inicio_manutencao AS data_inicio, data_fim_manutencao AS data_fim 
            FROM Manutencao 
            WHERE item_id = ? 
            ORDER BY data_inicio_manutencao DESC`;

        const [rows] = await db.execute(query, [id]);
        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erro ao buscar manutenção' });
    }
});

// Rota para listar as conversas do usuário logado
app.get('/api/mensagens/conversas/:usuarioId', async (req, res) => {
    try {
        const { usuarioId } = req.params;

        const query = `
            SELECT 
                m.item_id,
                i.nome_item,
                CASE 
                    WHEN m.remetente_id = ? THEN m.destinatario_id 
                    ELSE m.remetente_id 
                END AS id_outro_usuario,
                u.nome_usuario AS nome_outro_usuario,
                MAX(m.horario_mensagem) AS ultima_mensagem_data
            FROM Mensagem m
            JOIN Item i ON m.item_id = i.id_item
            JOIN Usuario u ON u.id_usuario = (
                CASE 
                    WHEN m.remetente_id = ? THEN m.destinatario_id 
                    ELSE m.remetente_id 
                END
            )
            WHERE m.remetente_id = ? OR m.destinatario_id = ?
            GROUP BY m.item_id, id_outro_usuario, u.nome_usuario
            ORDER BY ultima_mensagem_data DESC
        `;

        // O usuarioId é passado 4 vezes para preencher todos os "?" da query
        const [rows] = await db.execute(query, [usuarioId, usuarioId, usuarioId, usuarioId]);
        res.json(rows);
    } catch (error) {
        console.error("Erro SQL na rota de conversas:", error);
        res.status(500).json({ error: "Erro interno ao buscar conversas" });
    }
});

// 2. Histórico de uma conversa específica (Item + Eu + Outro)
app.get('/api/mensagens/:itemId/:usuarioLogadoId/:outroUsuarioId', async (req, res) => {
    try {
        const { itemId, usuarioLogadoId, outroUsuarioId } = req.params;
        const query = `
            SELECT 
                remetente_id AS id_remetente, 
                texto_mensagem AS texto, 
                horario_mensagem AS data 
            FROM Mensagem 
            WHERE item_id = ? 
              AND (
                (remetente_id = ? AND destinatario_id = ?) OR 
                (remetente_id = ? AND destinatario_id = ?)
              )
            ORDER BY horario_mensagem ASC
        `;
        const [rows] = await db.execute(query, [itemId, usuarioLogadoId, outroUsuarioId, outroUsuarioId, usuarioLogadoId]);
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: "Erro ao buscar histórico" });
    }
});

// Enviar Mensagem
app.post('/api/mensagens', async (req, res) => {
    try {
        const { item_id, remetente_id, destinatario_id, texto_mensagem } = req.body;
        const query = `
            INSERT INTO Mensagem (hash_mensagem, item_id, remetente_id, destinatario_id, texto_mensagem) 
            VALUES (UUID(), ?, ?, ?, ?)
        `;
        await db.execute(query, [item_id, remetente_id, destinatario_id, texto_mensagem]);
        res.status(201).json({ message: "Mensagem enviada!" });
    } catch (error) {
        res.status(500).json({ error: "Erro ao enviar mensagem" });
    }
});

app.get('/api/usuario/completo/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const query = `
            SELECT 
                u.nome_usuario, u.email, u.saldo, u.data_nascimento, u.cep,
                m.tipo_mensalidade,
                tp.nome_tipo AS nome_tipo_pessoa,
                e.logradouro, e.numero, e.bairro, e.cidade, e.estado, f.endereco_cdn
            FROM Usuario u
            LEFT JOIN Mensalidade_tipo m ON u.mensalidade_id = m.id_mensalidade
            LEFT JOIN TipoPessoa tp ON u.tipo_pessoa = tp.id_tipo_pessoa
            LEFT JOIN Endereco e ON u.endereco = e.id_endereco
            LEFT JOIN FOTO f ON f.id_foto = u.foto_perfil_id
            WHERE u.id_usuario = ?
        `;
        const [rows] = await db.execute(query, [id]);
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: "Erro ao buscar dados do perfil" });
    }
});

// Atualizar perfil do usuário
app.put('/api/usuario/:id', async (req, res) => {
    const { id } = req.params;
    const {
        nome_usuario,
        email,
        senha,
        data_nascimento,
        cep,
        logradouro,
        numero,
        complemento,
        bairro,
        cidade,
        estado,
        foto_url
    } = req.body || {};

    const conn = await db.getConnection();

    try {
        await conn.beginTransaction();

        const [usuarios] = await conn.execute('SELECT endereco, foto_perfil_id FROM Usuario WHERE id_usuario = ?', [id]);
        if (usuarios.length === 0) {
            await conn.rollback();
            return res.status(404).json({ error: 'Usuário não encontrado' });
        }

        const usuarioAtual = usuarios[0];
        const enderecoId = await upsertEndereco(conn, usuarioAtual.endereco, {
            cep,
            logradouro,
            numero,
            complemento,
            bairro,
            cidade,
            estado
        });

        let fotoId = null;
        if (isNonEmptyString(foto_url)) {
            fotoId = await inserirFoto(conn, foto_url);
        }

        const updates = [];
        const params = [];

        if (isNonEmptyString(nome_usuario)) {
            updates.push('nome_usuario = ?');
            params.push(nome_usuario);
        }
        if (isNonEmptyString(email)) {
            updates.push('email = ?');
            params.push(email);
        }
        if (isNonEmptyString(data_nascimento)) {
            updates.push('data_nascimento = ?');
            params.push(data_nascimento);
        }
        if (cep !== undefined) {
            updates.push('cep = ?');
            params.push(cep || null);
        }
        if (enderecoId) {
            updates.push('endereco = ?');
            params.push(enderecoId);
        }
        if (fotoId) {
            updates.push('foto_perfil_id = ?');
            params.push(fotoId);
        }
        if (isNonEmptyString(senha)) {
            const hash = await bcrypt.hash(senha, 10);
            updates.push('hash_senha = ?');
            params.push(hash);
        }

        if (updates.length === 0) {
            await conn.rollback();
            return res.status(400).json({ error: 'Nenhum campo para atualizar' });
        }

        params.push(id);
        await conn.execute(`UPDATE Usuario SET ${updates.join(', ')} WHERE id_usuario = ?`, params);

        await conn.commit();
        res.json({ success: true });
    } catch (error) {
        await conn.rollback();
        console.error('Erro ao atualizar perfil:', error);
        if (error.message === 'Dados de endereço incompletos') {
            return res.status(400).json({ error: 'Dados de endereço incompletos' });
        }
        if (error.message === 'Endereço não encontrado') {
            return res.status(404).json({ error: 'Endereço não encontrado' });
        }
        res.status(500).json({ error: 'Erro ao atualizar perfil' });
    } finally {
        conn.release();
    }
});

// Adicionar item
app.post('/api/itens', async (req, res) => {
    const { dono_id, nome_item, categoria, disponibilidade, estado_conservacao, descricao, foto_url } = req.body || {};

    if (!dono_id || !isNonEmptyString(nome_item) || !disponibilidade || !estado_conservacao) {
        return res.status(400).json({ error: 'Campos obrigatórios: dono_id, nome_item, disponibilidade, estado_conservacao' });
    }

    const conn = await db.getConnection();

    try {
        await conn.beginTransaction();

        const [result] = await conn.execute(
            `INSERT INTO Item (dono_id, nome_item, categoria, disponibilidade, descricao, estado_conservacao)
             VALUES (?, ?, ?, ?, ?, ?)`,
            [dono_id, nome_item, categoria || null, disponibilidade, descricao || null, estado_conservacao]
        );

        const itemId = result.insertId;

        if (isNonEmptyString(foto_url)) {
            const fotoId = await inserirFoto(conn, foto_url);
            await conn.execute('INSERT INTO Foto_item (foto_id, item_id) VALUES (?, ?)', [fotoId, itemId]);
        }

        await conn.commit();
        res.status(201).json({ success: true, id_item: itemId });
    } catch (error) {
        await conn.rollback();
        console.error('Erro ao adicionar item:', error);
        res.status(500).json({ error: 'Erro ao adicionar item' });
    } finally {
        conn.release();
    }
});

// Editar item
app.put('/api/itens/:id', async (req, res) => {
    const { id } = req.params;
    const { dono_id, nome_item, categoria, disponibilidade, estado_conservacao, descricao, foto_url } = req.body || {};

    const conn = await db.getConnection();

    try {
        await conn.beginTransaction();

        const [itens] = await conn.execute('SELECT dono_id FROM Item WHERE id_item = ?', [id]);
        if (itens.length === 0) {
            await conn.rollback();
            return res.status(404).json({ error: 'Item não encontrado' });
        }

        if (dono_id && itens[0].dono_id !== Number(dono_id)) {
            await conn.rollback();
            return res.status(403).json({ error: 'Sem permissão para editar este item' });
        }

        const updates = [];
        const params = [];

        if (isNonEmptyString(nome_item)) {
            updates.push('nome_item = ?');
            params.push(nome_item);
        }
        if (categoria !== undefined) {
            updates.push('categoria = ?');
            params.push(categoria || null);
        }
        if (disponibilidade !== undefined) {
            updates.push('disponibilidade = ?');
            params.push(disponibilidade);
        }
        if (estado_conservacao !== undefined) {
            updates.push('estado_conservacao = ?');
            params.push(estado_conservacao);
        }
        if (descricao !== undefined) {
            updates.push('descricao = ?');
            params.push(descricao || null);
        }

        if (updates.length === 0 && !isNonEmptyString(foto_url)) {
            await conn.rollback();
            return res.status(400).json({ error: 'Nenhum campo para atualizar' });
        }

        if (updates.length > 0) {
            params.push(id);
            await conn.execute(`UPDATE Item SET ${updates.join(', ')} WHERE id_item = ?`, params);
        }

        if (isNonEmptyString(foto_url)) {
            const fotoId = await inserirFoto(conn, foto_url);
            await conn.execute('INSERT INTO Foto_item (foto_id, item_id) VALUES (?, ?)', [fotoId, id]);
        }

        await conn.commit();
        res.json({ success: true });
    } catch (error) {
        await conn.rollback();
        console.error('Erro ao editar item:', error);
        res.status(500).json({ error: 'Erro ao editar item' });
    } finally {
        conn.release();
    }
});

// Rota para histórico de transações do usuário
app.get('/api/usuario/:id/transacoes', async (req, res) => {
    try {
        const { id } = req.params;
        const query = `
            SELECT i.nome_item, trans.tipo_transacao, t.data_transacao
            FROM Transacao t
            JOIN Item i ON t.item_id = i.id_item
            JOIN Transacao_tipo trans ON t.tipo_transacao = trans.id_transacao_tipo
            WHERE t.comprador_id = ?

            UNION

            SELECT i.nome_item, trans.tipo_transacao, t.data_transacao
            FROM Transacao t
            JOIN Item i ON t.item_id = i.id_item
            JOIN Transacao_tipo trans ON t.tipo_transacao = trans.id_transacao_tipo
            WHERE i.dono_id = ?

            ORDER BY data_transacao DESC`;
        const [rows] = await db.execute(query, [id, id]);
        res.json(rows);
    } catch (e) {
        res.status(500).json({ error: "Erro ao buscar transações" });
    }
});

const PORT = 3000;
app.listen(PORT, () => console.log(`🚀 Servidor EcoShare rodando na porta ${PORT}`));