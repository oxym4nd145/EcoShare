const express = require('express');
const cors = require('cors');
const db = require('./db'); 

const app = express();
app.use(cors());
app.use(express.json());

// --- Rota de Login ---
app.post('/api/login', async (req, res) => {
    const { email, senha } = req.body;

    if (!email || !senha) {
        return res.status(400).json({ error: 'Email e senha são obrigatórios' });
    }

    try {
        // Busca o usuário. Nota: Em produção, use bcrypt para comparar o hash_senha
        const query = 'SELECT id_usuario, nome_usuario FROM Usuario WHERE email = ? AND hash_senha = ?';
        const [rows] = await db.execute(query, [email, senha]);

        if (rows.length > 0) {
            const user = rows[0];
            res.json({ 
                success: true, 
                id: user.id_usuario, 
                nome: user.nome_usuario 
            });
        } else {
            res.status(401).json({ success: false, error: 'Email ou senha incorretos' });
        }
    } catch (error) {
        console.error("Erro no login:", error);
        res.status(500).json({ error: 'Erro interno no servidor' });
    }
});

// --- Rotas Auxiliares (Categorias, Status, etc) ---
app.get('/api/categorias', async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM Categoria_tipo');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: 'Erro ao buscar categorias' });
    }
});

app.get('/api/transacoes', async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM Transacao_tipo');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: 'Erro ao buscar tipos de transações' });
    }
});

// --- Listagem de Itens (Home com Filtros) ---
app.get('/api/itens', async (req, res) => {
    try {
        const { cat, disp, est, busca } = req.query; 
        
        let query = `
            SELECT 
                i.id_item AS _id, 
                i.nome_item AS nome, 
                i.descricao, 
                cat.tipo_categoria AS categoria, 
                est.tipo_estado AS condicao, 
                disp.tipo_status AS tipo,
                MAX(f.endereco_cdn) AS foto
            FROM Item i 
            LEFT JOIN Categoria_tipo cat ON i.categoria = cat.id_categoria 
            LEFT JOIN Estado_tipo est ON i.estado_conservacao = est.id_estado 
            LEFT JOIN Status_tipo disp ON i.status_item = disp.id_status
            LEFT JOIN Usuario u ON i.dono_id = u.id_usuario
            LEFT JOIN Endereco endr ON u.endereco_id = endr.id_endereco
            LEFT JOIN Foto_item fitem ON fitem.item_id = i.id_item
            LEFT JOIN Foto f ON fitem.foto_id = f.id_foto
            WHERE 1=1
        `;

        const params = [];

        if (cat) { query += ` AND i.categoria = ?`; params.push(cat); }
        if (disp) { query += ` AND i.status_item = ?`; params.push(disp); }

        // `est` pode ser:
        // - um id numérico (estado de conservação) -> filtra i.estado_conservacao
        // - uma sigla UF (ex: 'SP') -> filtra pelo estado do endereço do dono (endr.estado)
        if (est) {
            const estIsId = /^\d+$/.test(est);
            if (estIsId) {
                query += ` AND i.estado_conservacao = ?`;
                params.push(est);
            } else {
                query += ` AND endr.estado = ?`;
                params.push(est);
            }
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

// --- Detalhes de um Item ---
app.get('/api/itens/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const query = `
            SELECT 
                i.id_item AS _id, 
                i.nome_item AS nome, 
                i.descricao AS descricao, 
                cat.tipo_categoria AS categoria, 
                disp.tipo_status AS tipo,
                est.tipo_estado AS estado,
                i.dono_id AS dono_id, -- AQUI: Adicionei a vírgula que faltava
                u.nome_usuario AS dono,
                endr.cidade AS localizacao,
                f.endereco_cdn AS foto
            FROM Item i 
            LEFT JOIN Categoria_tipo cat ON i.categoria = cat.id_categoria 
            LEFT JOIN Status_tipo disp ON i.status_item = disp.id_status 
            LEFT JOIN Estado_tipo est ON i.estado_conservacao = est.id_estado
            LEFT JOIN Usuario u ON i.dono_id = u.id_usuario
            LEFT JOIN Endereco endr ON u.endereco_id = endr.id_endereco
            LEFT JOIN Foto_item fitem ON fitem.item_id = i.id_item
            LEFT JOIN Foto f ON fitem.foto_id = f.id_foto
            WHERE i.id_item = ? 
            LIMIT 1`;

        const [rows] = await db.execute(query, [id]);
        if (rows.length === 0) return res.status(404).json({ error: 'Item não encontrado' });
        res.json(rows[0]);
    } catch (error) {
        console.error("Erro no SQL:", error); // Adicionado para debugar
        res.status(500).json({ error: 'Erro ao buscar item' });
    }
});

// --- Perfil Completo do Usuário ---
app.get('/api/usuario/completo/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const query = `
            SELECT 
                u.nome_usuario, u.email, u.saldo, u.data_nascimento,
                m.tipo_mensalidade,
                tp.nome_tipo AS nome_tipo_pessoa,
                e.cep, e.logradouro, e.numero, e.bairro, e.cidade, e.estado, 
                f.endereco_cdn AS foto_perfil
            FROM Usuario u
            LEFT JOIN Mensalidade_tipo m ON u.mensalidade_id = m.id_mensalidade
            LEFT JOIN TipoPessoa tp ON u.tipo_pessoa = tp.id_tipo_pessoa
            LEFT JOIN Endereco e ON u.endereco_id = e.id_endereco -- Alterado para endereco_id
            LEFT JOIN Foto f ON f.id_foto = u.foto_perfil_id
            WHERE u.id_usuario = ?
        `;
        const [rows] = await db.execute(query, [id]);
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: "Erro ao buscar dados" });
    }
});

// Atualizar campos mutáveis do usuário (não permite alterar id_usuario)
app.put('/api/usuario/:id', async (req, res) => {
    try {
        const { id } = req.params;

        // Proteger id_usuario: se enviado no body e diferente, rejeita
        if (req.body.id_usuario && String(req.body.id_usuario) !== String(id)) {
            return res.status(400).json({ error: 'Não é permitido alterar id_usuario' });
        }

        // Validação de formato de email: sem espaços e no formato local@dominio.tld
        if (req.body.email) {
            const email = String(req.body.email);
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                return res.status(400).json({ error: 'Email em formato inválido' });
            }
        }

        // Validação de senha: maior que 6 caracteres e sem espaços
        if (req.body.hash_senha) {
            const senha = String(req.body.hash_senha);
            if (senha.length <= 6) {
                return res.status(400).json({ error: 'Senha deve ter mais de 6 caracteres' });
            }
            if (/\s/.test(senha)) {
                return res.status(400).json({ error: 'Senha não pode conter espaços' });
            }
        }

        // Campos permitidos para atualização
        const allowed = [
            'nome_usuario',
            'email',
            'foto_perfil_id',
            'tipo_pessoa',
            'hash_senha',
            'data_nascimento',
            'endereco_id'
        ];

        const updates = [];
        const params = [];

        for (const key of allowed) {
            if (Object.prototype.hasOwnProperty.call(req.body, key)) {
                updates.push(`${key} = ?`);
                params.push(req.body[key]);
            }
        }

        if (updates.length === 0) {
            return res.status(400).json({ error: 'Nenhum campo válido para atualizar foi enviado' });
        }

        // Se email foi enviado, garantir que não exista para outro usuário
        if (req.body.email) {
            const [rows] = await db.execute('SELECT id_usuario FROM Usuario WHERE email = ? AND id_usuario <> ?', [req.body.email, id]);
            if (rows.length > 0) {
                return res.status(409).json({ error: 'Email já está em uso por outro usuário' });
            }
        }

        const sql = `UPDATE Usuario SET ${updates.join(', ')} WHERE id_usuario = ?`;
        params.push(id);

        await db.execute(sql, params);

        const [updated] = await db.execute('SELECT id_usuario, nome_usuario, email, foto_perfil_id, tipo_pessoa, data_nascimento, endereco_id FROM Usuario WHERE id_usuario = ?', [id]);
        res.json({ success: true, usuario: updated[0] });
    } catch (err) {
        console.error('Erro ao atualizar usuário:', err);
        res.status(500).json({ error: 'Erro ao atualizar usuário' });
    }
});

// Excluir conta do usuário
app.delete('/api/usuario/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const [result] = await db.execute('DELETE FROM Usuario WHERE id_usuario = ?', [id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Usuário não encontrado' });
        }

        res.json({ success: true });
    } catch (err) {
        console.error('Erro ao excluir usuário:', err);
        res.status(409).json({ error: 'Não foi possível excluir o usuário. Verifique dependências vinculadas.' });
    }
});

// --- Cadastro de Usuário ---
app.post('/api/cadastrar', async (req, res) => {
    const { nome, email, senha, data_nascimento, nivel_permissao, mensalidade_id } = req.body;

    try {
        const sql = `
            INSERT INTO Usuario 
            (nome_usuario, email, hash_senha, data_nascimento, nivel_permissao, mensalidade_id) 
            VALUES (?, ?, ?, ?, ?, ?)
        `;
        
        // Usando await db.execute para consistência com o restante do arquivo
        await db.execute(sql, [
            nome, 
            email, 
            senha, 
            data_nascimento, 
            nivel_permissao || 2, // Default: Conta Ativa
            mensalidade_id || 1,   // Default: Sem mensalidade
        ]);

        res.json({ success: true });
    } catch (err) {
        console.error("ERRO NO CADASTRO:", err);
        res.status(500).json({ success: false, error: err.message });
    }
});

// Adicionar item
app.post('/api/itens', async (req, res) => {
    try {
        const { dono_id, nome_item, categoria, status_item, descricao, estado_conservacao } = req.body;

        if (!dono_id || !nome_item || !status_item || !estado_conservacao) {
            return res.status(400).json({ error: 'Campos obrigatórios: dono_id, nome_item, status_item, estado_conservacao' });
        }

        const sql = `
            INSERT INTO Item (dono_id, nome_item, categoria, status_item, descricao, estado_conservacao)
            VALUES (?, ?, ?, ?, ?, ?)
        `;

        const [result] = await db.execute(sql, [
            dono_id,
            nome_item,
            categoria || null,
            status_item,
            descricao || null,
            estado_conservacao
        ]);

        res.status(201).json({ success: true, id_item: result.insertId });
    } catch (err) {
        console.error('Erro ao inserir item:', err);
        res.status(500).json({ error: 'Erro ao inserir item' });
    }
});

// Editar informações do item e/ou registrar manutenção
app.put('/api/itens/:id', async (req, res) => {
    const conn = await db.getConnection();
    try {
        const { id } = req.params;
        const {
            nome_item,
            categoria,
            status_item,
            descricao,
            estado_conservacao,
            manutencao
        } = req.body;

        const updates = [];
        const params = [];

        if (nome_item !== undefined) { updates.push('nome_item = ?'); params.push(nome_item); }
        if (categoria !== undefined) { updates.push('categoria = ?'); params.push(categoria); }
        if (status_item !== undefined) { updates.push('status_item = ?'); params.push(status_item); }
        if (descricao !== undefined) { updates.push('descricao = ?'); params.push(descricao); }
        if (estado_conservacao !== undefined) { updates.push('estado_conservacao = ?'); params.push(estado_conservacao); }

        const hasManutencao = manutencao && (manutencao.data_inicio_manutencao || manutencao.data_fim_manutencao);

        if (updates.length === 0 && !hasManutencao) {
            return res.status(400).json({ error: 'Nenhum campo válido para atualizar foi enviado' });
        }

        await conn.beginTransaction();

        if (updates.length > 0) {
            const sql = `UPDATE Item SET ${updates.join(', ')} WHERE id_item = ?`;
            params.push(id);
            const [result] = await conn.execute(sql, params);
            if (result.affectedRows === 0) {
                await conn.rollback();
                return res.status(404).json({ error: 'Item não encontrado' });
            }
        }

        if (hasManutencao) {
            if (!manutencao.data_inicio_manutencao) {
                await conn.rollback();
                return res.status(400).json({ error: 'data_inicio_manutencao é obrigatória para manutenção' });
            }

            await conn.execute(
                `INSERT INTO Manutencao (item_id, data_inicio_manutencao, data_fim_manutencao)
                 VALUES (?, ?, ?)`
                , [id, manutencao.data_inicio_manutencao, manutencao.data_fim_manutencao || null]
            );
        }

        await conn.commit();

        res.json({ success: true });
    } catch (err) {
        await conn.rollback();
        console.error('Erro ao atualizar item/manutenção:', err);
        res.status(500).json({ error: 'Erro ao atualizar item/manutenção' });
    } finally {
        conn.release();
    }
});

// Excluir item
app.delete('/api/itens/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const [result] = await db.execute('DELETE FROM Item WHERE id_item = ?', [id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Item não encontrado' });
        }

        res.json({ success: true });
    } catch (err) {
        console.error('Erro ao excluir item:', err);
        res.status(409).json({ error: 'Não foi possível excluir o item. Verifique dependências vinculadas.' });
    }
});

// Buscar Tipos de Disponibilidade
app.get('/api/disponibilidades', async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM Status_tipo');
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

app.get('/api/usuario/:usuarioId/itens', async (req, res) => {
    try {
        // Agora o nome aqui casa com o nome na URL acima
        const { usuarioId } = req.params; 
        
        const query = `
            SELECT 
                i.id_item AS _id, 
                i.nome_item AS nome, 
                disp.tipo_status AS tipo,
                ANY_VALUE(f.endereco_cdn) AS foto
            FROM Item i
            LEFT JOIN Status_tipo disp ON i.status_item = disp.id_status
            LEFT JOIN Foto_item fitem ON fitem.item_id = i.id_item
            LEFT JOIN Foto f ON fitem.foto_id = f.id_foto
            WHERE i.dono_id = ?
            GROUP BY i.id_item`;

        const [rows] = await db.execute(query, [usuarioId]);
        
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
                u_avaliador.nome_usuario
            FROM Avaliacao a 
            INNER JOIN Transacao t ON a.transacao_id = t.id_transacao
            INNER JOIN Item i ON t.item_id = i.id_item
            INNER JOIN Usuario u_avaliador ON a.avaliador_id = u_avaliador.id_usuario 
            WHERE t.item_id = ? 
              AND a.avaliador_id <> i.dono_id  -- Garante que pegamos apenas avaliações de quem NÃO é o dono
            ORDER BY t.data_transacao DESC
        `;

        const [rows] = await db.execute(queryAvaliacoes, [id]);
        res.json(rows);
    } catch (error) {
        console.error("Erro ao buscar avaliações:", error);
        res.status(500).json({ error: 'Erro ao buscar avaliações do comprador' });
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
        
        // Validação simples
        if(!item_id || !remetente_id || !destinatario_id) {
            return res.status(400).json({ error: "Campos obrigatórios ausentes" });
        }

        const query = `
            INSERT INTO Mensagem (hash_mensagem, item_id, remetente_id, destinatario_id, texto_mensagem) 
            VALUES (UUID(), ?, ?, ?, ?)
        `;
        await db.execute(query, [item_id, remetente_id, destinatario_id, texto_mensagem]);
        res.status(201).json({ message: "Mensagem enviada!" });
    } catch (error) {
        console.error("Erro SQL no POST:", error);
        res.status(500).json({ error: "Erro ao inserir no banco" });
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