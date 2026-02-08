const express = require('express');
const cors = require('cors');
const db = require('./db'); 

const app = express();
app.use(cors());
app.use(express.json());

// Rota para buscar as categorias dinâmicas
app.get('/api/categorias', async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM Categoria_tipo');
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: 'Erro ao buscar categorias' });
    }
});

// 1. ROTA HOME: Listar todos os itens
app.get('/api/itens', async (req, res) => {
    try {
        const { cat } = req.query; 
        
        // 1. A Query agora tem um WHERE fixo para disponibilidade = 1 (Disponível)
        let query = `
            SELECT 
                i.id_item AS _id, 
                i.nome_item AS nome, 
                i.descricao, 
                cat.tipo_categoria AS categoria, 
                est.tipo_estado AS condicao, 
                disp.tipo_disponibilidade AS tipo 
            FROM Item i 
            LEFT JOIN Categoria_tipo cat ON i.categoria = cat.id_categoria 
            LEFT JOIN Estado_tipo est ON i.estado_conservacao = est.id_estado 
            LEFT JOIN Disponibilidade_tipo disp ON i.disponibilidade = disp.id_disponibilidade
            WHERE i.disponibilidade = 1
        `;

        const params = [];
        // 2. Se houver categoria, adicionamos ao WHERE existente
        if (cat) {
            query += ` AND i.categoria = ?`;
            params.push(cat);
        }

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
                disp.tipo_disponibilidade AS tipo 
            FROM Item i 
            LEFT JOIN Categoria_tipo cat ON i.categoria = cat.id_categoria 
            LEFT JOIN Disponibilidade_tipo disp ON i.disponibilidade = disp.id_disponibilidade 
            WHERE i.id_item = ?`;
        const [rows] = await db.execute(query, [id]);
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: 'Erro ao buscar item' });
    }
});

// 3. ROTA MENSAGENS: Buscar histórico de chat de um item
// No seu banco, as mensagens são vinculadas ao item_id
app.get('/api/mensagens/:itemId', async (req, res) => {
    try {
        const { itemId } = req.params;
        const query = `
            SELECT 
                remetente_id AS id_remetente, 
                texto_mensagem AS texto, 
                horario_mensagem AS data 
            FROM Mensagem 
            WHERE item_id = ? 
            ORDER BY horario_mensagem ASC
        `;
        const [rows] = await db.execute(query, [itemId]);
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: "Erro ao buscar mensagens" });
    }
});

// 4. ROTA ENVIAR MENSAGEM: Salvar no banco
app.post('/api/mensagens', async (req, res) => {
    try {
        const { item_id, remetente_id, texto_mensagem } = req.body;
        // O hash_mensagem é gerado automaticamente pelo banco (UUID)
        const query = `
            INSERT INTO Mensagem (item_id, remetente_id, texto_mensagem, horario_mensagem) 
            VALUES (?, ?, ?, NOW())
        `;
        await db.execute(query, [item_id, remetente_id, texto_mensagem]);
        res.status(201).json({ message: "Mensagem enviada!" });
    } catch (error) {
        console.error(error);
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
                e.logradouro, e.numero, e.bairro, e.cidade, e.estado
            FROM Usuario u
            LEFT JOIN Mensalidade_tipo m ON u.mensalidade_id = m.id_mensalidade
            LEFT JOIN TipoPessoa tp ON u.tipo_pessoa = tp.id_tipo_pessoa
            LEFT JOIN Endereco e ON u.endereco = e.id_endereco
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
            SELECT i.nome_item, disp.tipo_disponibilidade, t.data_inicio, s.status_pagamento
            FROM Transacao t
            JOIN Item i ON t.item_id = i.id_item
            JOIN Disponibilidade_tipo disp ON i.disponibilidade = disp.id_disponibilidade
            LEFT JOIN Status_pagamento_tipo s ON t.status_pagamento = s.id_status_pagamento
            WHERE t.comprador_id = ? OR i.dono_id = ?
            ORDER BY t.data_inicio DESC`;
        const [rows] = await db.execute(query, [id, id]);
        res.json(rows);
    } catch (e) {
        res.status(500).json({ error: "Erro ao buscar transações" });
    }
});

const PORT = 3000;
app.listen(PORT, () => console.log(`🚀 Servidor EcoShare rodando na porta ${PORT}`));