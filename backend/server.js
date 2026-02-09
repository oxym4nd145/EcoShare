const express = require('express');
const cors = require('cors');
const db = require('./db'); 

const app = express();
app.use(cors());
app.use(express.json());

// Rota de Login
app.post('/api/login', async (req, res) => {
    const { email, senha } = req.body;

    if (!email || !senha) {
        return res.status(400).json({ error: 'Email e senha são obrigatórios' });
    }

    try {
        // CORREÇÃO: Usando 'hash_senha' conforme seu esquema
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

// 2. ROTA DETALHES: Buscar um item por ID
app.get('/api/itens/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const query = `
            SELECT 
                i.id_item AS _id, 
                i.nome_item AS nome, 
                i.descricao, 
                cat.tipo_categoria AS categoria,
                disp.tipo_disponibilidade AS tipo,
                f.endereco_cdn AS foto
            FROM Item i 
            LEFT JOIN Categoria_tipo cat ON i.categoria = cat.id_categoria 
            LEFT JOIN Disponibilidade_tipo disp ON i.disponibilidade = disp.id_disponibilidade 
            -- ADICIONADO OS JOINS ABAIXO PARA PEGAR A FOTO
            LEFT JOIN Foto_item fitem ON fitem.item_id = i.id_item
            LEFT JOIN Foto f ON fitem.foto_id = f.id_foto
            WHERE i.id_item = ?
            LIMIT 1`; // Garante que pega apenas uma linha (caso tenha múltiplas fotos, pega a primeira)
            
        const [rows] = await db.execute(query, [id]);
        
        // Verificação de segurança caso o ID não exista
        if (rows.length === 0) {
            return res.status(404).json({ error: 'Item não encontrado' });
        }

        res.json(rows[0]);
    } catch (error) {
        console.error(error); // Bom para debugar no console
        res.status(500).json({ error: 'Erro ao buscar item' });
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