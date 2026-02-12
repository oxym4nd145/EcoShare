-- 1. View da Média da Avaliação por Usuário
CREATE VIEW Media_avaliacao AS
SELECT
    a.avaliado_id AS 'ID do Usuário',
    u.nome_usuario AS 'Nome do Usuário',
    AVG(a.nota) AS 'Média de Avaliações',
    COUNT(*) AS 'Quantidade de Avaliações'
FROM
    Avaliacao a
JOIN
    Usuario u ON a.avaliado_id = u.id_usuario
GROUP BY
    a.avaliado_id, u.nome_usuario;

-- 2. View de Pessoas Físicas com CPF
CREATE VIEW Pessoa_fisica AS
SELECT
    u.id_usuario AS 'ID do Usuário',
    u.nome_usuario AS 'Nome do Pessoa Física',
    c.cpf AS 'Número do CPF',
    u.email AS 'Email',
    m.tipo_mensalidade AS 'Tipo de Mensalidade',
    u.saldo AS 'Saldo',
    u.data_nascimento AS 'Data de Nascimento',
    e.cidade AS 'Município',
    e.estado AS 'Estado'
FROM
    Usuario u
JOIN
    Mensalidade_tipo m ON u.mensalidade_id = m.id_mensalidade
JOIN
    Cpf c ON u.id_usuario = c.usuario_id
JOIN
    Endereco e ON u.endereco_id = e.id_endereco
WHERE
    u.tipo_pessoa = 1;

-- 3. View de Pessoas Jurídicas com CNPJ
CREATE VIEW Pessoa_juridica AS
SELECT
    u.id_usuario AS 'ID do Usuário',
    u.nome_usuario AS 'Nome da Pessoa Jurídica',
    cj.cnpj AS 'Número do CNPJ',
    u.email AS 'Email',
    m.tipo_mensalidade AS 'Tipo de Mensalidade',
    u.saldo AS 'Saldo',
    e.cidade AS 'Município',
    e.estado AS 'Estado'
FROM
    Usuario u
JOIN
    Mensalidade_tipo m ON u.mensalidade_id = m.id_mensalidade
JOIN
    Cnpj cj ON u.id_usuario = cj.usuario_id
JOIN
    Endereco e ON u.endereco_id = e.id_endereco
WHERE
    u.tipo_pessoa = 2;

-- 4. View de Itens Disponíveis
CREATE VIEW Item_disponivel AS
SELECT
    i.nome_item AS 'Nome do Item',
    i.descricao AS 'Descrição',
    c.tipo_categoria AS 'Categoria',
    e.tipo_estado AS 'Estado de Conservação'
FROM
    Item i
JOIN
    Estado_tipo e ON i.estado_conservacao = e.id_estado
LEFT JOIN
    Categoria_tipo c ON i.categoria = c.id_categoria
WHERE   
    i.status_item = (SELECT id_status FROM Status_tipo WHERE tipo_status = 'Disponível');


-- 5. View de Itens por Categoria
CREATE VIEW Item_por_categoria AS
SELECT
    c.tipo_categoria AS `Categoria`,
    COUNT(*) AS `Total de Itens`,
    SUM(s.tipo_status = 'Disponível') AS `Itens Disponíveis`,
    SUM(s.tipo_status = 'Indisponível') AS `Itens Indisponíveis`,
    SUM(s.tipo_status = 'Em Uso') AS `Itens em Uso`,
    SUM(s.tipo_status = 'Em Manutenção') AS `Itens em Manutenção`
FROM 
    Item i
JOIN 
    Categoria_tipo c ON i.categoria = c.id_categoria
JOIN 
    Status_tipo s ON i.status_item = s.id_status
GROUP BY 
    c.tipo_categoria;

-- 6. View de Itens por Estado de Conservação
CREATE VIEW Item_por_estado AS
SELECT
    e.tipo_estado AS 'Estado de Conservação',
    COUNT(i.id_item) AS 'Total de Itens'
FROM
    Item i
JOIN
    Estado_tipo e ON i.estado_conservacao = e.id_estado
GROUP BY
    e.tipo_estado;

-- 7. View de Itens por Usuário
CREATE VIEW Item_por_usuario AS
SELECT
    u.nome_usuario AS 'Nome do Usuário',
    COUNT(i.id_item) AS 'Total de Itens'
FROM
    Item i
JOIN
    Usuario u ON i.dono_id = u.id_usuario
GROUP BY
    u.nome_usuario;

-- 8. View de Transações por Tipo
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

-- 9. View de Itens em Manutenção
CREATE VIEW Item_em_manutencao AS
SELECT
    i.id_item AS 'ID do Item',
    i.nome_item AS 'Nome do Item',
    u.nome_usuario AS 'Dono do Item',
    c.tipo_categoria AS 'Categoria',
    i.descricao AS 'Descrição',
    e.tipo_estado AS 'Estado de Conservação'
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

-- 10. View de Itens mais Populares (mais transacionados)
CREATE VIEW Item_popular AS
SELECT
    i.nome_item AS 'Nome do Item',
    COUNT(t.id_transacao) AS 'Total de Transações'
FROM
    Item i
JOIN
    Transacao t ON i.id_item = t.item_id
GROUP BY
    i.nome_item
ORDER BY
    'Total de Transações' DESC
LIMIT 10;

-- 11. Denuncias mais recentes
CREATE VIEW Ultimas_denuncias AS
SELECT
    d.id_denuncia AS 'ID da denúncia',
    d.denuncia_data AS 'Data da denúncia',
    d.denuncia_denunciador_id AS 'ID do denunciador',
    d.denuncia_alvo_id AS 'ID do objeto denunciado',
    alvo.tipo_objeto AS 'Tipo do objeto denunciado',
    d.denuncia_conteudo AS 'Texto da denúncia',
    de.denuncia_estado AS 'Estado da denuncia'
FROM
    Denuncia as d
JOIN 
    Alvo_ID as alvo
        ON d.denuncia_alvo_id = alvo.id_alvo  
JOIN
    Denuncia_estado as de
        ON d.denuncia_estado = de.id_denuncia_estado
ORDER BY 
    'Data da denúncia' DESC;

-- 12. Denúncias mais antigas ainda em aberto 
CREATE VIEW Denuncias_abertas_mais_antigas AS
SELECT
    d.id_denuncia AS 'ID da denúncia',
    d.denuncia_data AS 'Data da denúncia',
    d.denuncia_alvo_id AS 'ID do objeto denunciado',
    alvo.tipo_objeto AS 'Tipo do objeto denunciado',
    d.denuncia_conteudo AS 'Texto da denúncia'
FROM
    Denuncia AS d
JOIN 
    Alvo_ID AS alvo
        ON d.denuncia_alvo_id = alvo.id_alvo
JOIN
    Denuncia_estado AS de 
        ON d.denuncia_estado = de.id_denuncia_estado
WHERE
    de.denuncia_estado = 'Aberto'
ORDER BY
    'Data da denúncia' ASC;

-- 13. Contagem de denúncias por estado
CREATE VIEW Denuncias_por_estado AS
SELECT
    de.denuncia_estado AS 'Estado da denúncia',
    COUNT(*) AS 'Número de denúncias'
FROM
    Denuncia AS d
JOIN
    Denuncia_estado AS de
        ON d.denuncia_estado = de.id_denuncia_estado
GROUP BY
    de.denuncia_estado