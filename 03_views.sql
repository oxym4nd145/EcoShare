-- 1. View da Média da Avaliação por Usuário
CREATE VIEW Media_avaliacao AS
SELECT
    a.avaliado_id AS "ID do Usuário",
    u.nome_usuario AS "Nome do Usuário",
    AVG(a.nota) AS "Média de Avaliações",
    COUNT(*) AS "Quantidade de Avaliações"
FROM
    Avaliacao a
JOIN
    Usuario u ON a.avaliado_id = u.id_usuario
GROUP BY
    a.avaliado_id, u.nome_usuario;

-- 2. View de Itens Disponíveis
CREATE VIEW Item_disponivel AS
SELECT
    i.nome_item AS "Nome do Item",
    i.descricao AS "Descrição",
    c.tipo_categoria AS "Categoria",
    e.tipo_estado AS "Estado de Conservação"
FROM
    Item i
JOIN
    Estado_tipo e ON i.estado_conservacao = e.id_estado
JOIN
    Categoria_tipo c ON i.categoria = c.id_categoria
WHERE   
    disponibilidade = (SELECT id_disponibilidade FROM Disponibilidade_tipo WHERE tipo_disponibilidade = 'Disponível');

-- 3. View de Itens por Categoria
CREATE VIEW Item_por_categoria AS
SELECT
    c.tipo_categoria AS "Categoria",
    COUNT(i.id_item) AS "Total de Itens"
FROM
    Item i
JOIN
    Categoria_tipo c ON i.categoria = c.id_categoria
GROUP BY
    c.tipo_categoria;

-- 4. View de Itens por Estado de Conservação
CREATE VIEW Item_por_estado AS
SELECT
    e.tipo_estado AS "Estado de Conservação",
    COUNT(i.id_item) AS "Total de Itens"
FROM
    Item i
JOIN
    Estado_tipo e ON i.estado_conservacao = e.id_estado
GROUP BY
    e.tipo_estado;

-- 5. View de Itens por Usuário
CREATE VIEW Item_por_usuario AS
SELECT
    u.nome_usuario AS "Nome do Usuário",
    COUNT(i.id_item) AS "Total de Itens"
FROM
    Item i
JOIN
    Usuario u ON i.dono_id = u.id_usuario
GROUP BY
    u.nome_usuario;

-- 6. View de Transações por Tipo
CREATE VIEW Transacao_por_tipo AS
SELECT
    tt.tipo_transacao AS tipo_transacao,
    COUNT(t.id_transacao) AS total_transacoes
FROM
    Transacao t
INNER JOIN 
    Transacao_tipo tt ON t.tipo_transacao = tt.id_transacao_tipo
GROUP BY
    tt.tipo_transacao;

-- 7. View de Itens em Manutenção
CREATE VIEW Item_em_manutencao AS
SELECT
    i.id_item AS "ID do Item",
    i.nome_item AS "Nome do Item",
    u.nome_usuario AS "Dono do Item",
    c.tipo_categoria AS "Categoria",
    i.descricao AS "Descrição",
    e.tipo_estado AS "Estado de Conservação"
FROM
    Item i
JOIN
    Usuario u ON i.dono_id = u.id_usuario
JOIN
    Manutencao m ON i.id_item = m.item_id
JOIN
    Estado_tipo e ON i.estado_conservacao = e.id_estado
JOIN
    Categoria_tipo c ON i.categoria = c.id_categoria
WHERE
    m.data_fim_manutencao IS NULL OR m.data_fim_manutencao > CURRENT_DATE;

-- 8. View de Itens mais Populares (mais transacionados)
CREATE VIEW Item_popular AS
SELECT
    i.nome_item AS "Nome do Item",
    COUNT(t.id_transacao) AS "Total de Transações"
FROM
    Item i
JOIN
    Transacao t ON i.id_item = t.item_id
GROUP BY
    i.nome_item
ORDER BY
    "Total de Transações" DESC
LIMIT 10;