-- Criação do Banco de Dados
CREATE DATABASE ECOSHARE;
USE ECOSHARE;

-- 1. Tabela de Tipos de Mensalidade
CREATE TABLE Mensalidade_tipo (
    id_mensalidade INT AUTO_INCREMENT,
    tipo_mensalidade VARCHAR(50) NOT NULL UNIQUE, -- Sem mensalidade, básica, plus

    PRIMARY KEY (id_mensalidade)
);

-- 2. Tabela de Usuários
CREATE TABLE Usuario (
    id_usuario INT AUTO_INCREMENT,
    mensalidade_id INT,
    nome_usuario VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    cpf CHAR(14) UNIQUE,
    cnpj CHAR(18) UNIQUE,
    hash_senha VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    endereco VARCHAR(255),
    cep CHAR(9),

    PRIMARY KEY (id_usuario),

    FOREIGN KEY (mensalidade_id) REFERENCES Mensalidade_tipo(id_mensalidade)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    CONSTRAINT usuario_com_cpf_e_cnpj CHECK (
    (cpf IS NOT NULL AND cnpj IS NULL) OR
    (cpf IS NULL AND cnpj IS NOT NULL))
);

-- 3. Tabela de Fotos de Perfil
CREATE TABLE Foto_perfil (
    id_foto_perfil INT AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    endereco_cdn VARCHAR(255) NOT NULL,

    PRIMARY KEY (id_foto_perfil),

    FOREIGN KEY (usuario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 4. Tabela de Tipos de Permissão
CREATE TABLE Permissao (
    id_permissao INT AUTO_INCREMENT,
    tipo_permissao VARCHAR(31) NOT NULL UNIQUE, -- Administrador, Moderador, Usuário

    PRIMARY KEY (id_permissao)
);

-- 5. Tabela de concessões de permissão
CREATE TABLE Permissao_usuario (
    usuario_id INT,
    permissao_id INT,

    PRIMARY KEY (usuario_id, permissao_id),

    FOREIGN KEY (usuario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (permissao_id) REFERENCES Permissao(id_permissao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 6. Tabela de Categorias de Itens
CREATE TABLE Categoria_tipo (
    id_categoria INT AUTO_INCREMENT,
    tipo_categoria VARCHAR(50) NOT NULL UNIQUE, -- Ferramentas, eletrônicos, etc.

    PRIMARY KEY (id_categoria)
);

-- 7. Tabela de Estados de Conservação
CREATE TABLE Estado_tipo (
    id_estado INT AUTO_INCREMENT,
    tipo_estado VARCHAR(50) NOT NULL UNIQUE, -- Novo, usado, seminovo

    PRIMARY KEY (id_estado)
);

-- 8. Tabela de Disponibilidades de Itens
CREATE TABLE Disponibilidade_tipo (
    id_disponibilidade INT AUTO_INCREMENT,
    tipo_disponibilidade VARCHAR(50) NOT NULL UNIQUE, -- Disponível, Não disponível (doado), Em uso (emprestad/alugado), Em manutenção

    PRIMARY KEY (id_disponibilidade)
);

-- 9. Tabela de Itens
CREATE TABLE Item (
    id_item INT AUTO_INCREMENT,
    dono_id INT NOT NULL,
    nome_item VARCHAR(100) NOT NULL,
    categoria INT,
    disponibilidade INT, 
    descricao TEXT,
    estado_conservacao INT,

    PRIMARY KEY (id_item),

    FOREIGN KEY (categoria) REFERENCES Categoria_tipo(id_categoria)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (dono_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (disponibilidade) REFERENCES Disponibilidade_tipo(id_disponibilidade)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (estado_conservacao) REFERENCES Estado_tipo(id_estado)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

-- 10. Tabela de Fotos de Itens
CREATE TABLE Foto_item (
    id_foto_item INT AUTO_INCREMENT,
    item_id INT NOT NULL,
    endereco_cdn VARCHAR(255) NOT NULL,

    PRIMARY KEY (id_foto_item),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 11. Tabela de Manutenção
CREATE TABLE Manutencao (
    id_manutencao INT AUTO_INCREMENT,
    item_id INT NOT NULL,
    data_inicio_manutencao DATE NOT NULL,
    data_fim_manutencao DATE,

    PRIMARY KEY (id_manutencao),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 12. Tabela de Mensagens (Chat)
CREATE TABLE Mensagem (
    hash_mensagem CHAR(36), -- UUID
    item_id INT NOT NULL,
    remetente_id INT,
    destinatario_id INT,
    texto_mensagem TEXT NOT NULL,
    horario_mensagem TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (hash_mensagem),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (remetente_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (destinatario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- 13. Tabela de Pontos de Coleta
CREATE TABLE Ponto_coleta (
    id_coleta INT AUTO_INCREMENT,
    nome_coleta VARCHAR(100) NOT NULL UNIQUE,
    endereco_coleta VARCHAR(255),

    PRIMARY KEY (id_coleta)
);

-- 14. Tabela de Transações
CREATE TABLE Transacao (
    id_transacao INT AUTO_INCREMENT,
    item_id INT NOT NULL,
    vendedor_id INT NOT NULL,
    comprador_id INT,
    coleta_id INT,
    data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_coleta TIMESTAMP,

    PRIMARY KEY (id_transacao),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (vendedor_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (comprador_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (coleta_id) REFERENCES Ponto_coleta(id_coleta)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- 15. Tabela de Transações de Aluguel
CREATE TABLE Aluguel (
    transacao_id INT,
    prev_devolucao DATE NOT NULL,
    data_devolucao DATE,
    preco DECIMAL(10, 2) NOT NULL,
    multa DECIMAL(10, 2), -- Gabriel: regra de negócio ctz

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 16. Tabela de Transações de Doação
CREATE TABLE Doacao (
    transacao_id INT,

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 17. Tabela de Transações de Empréstimo
CREATE TABLE Emprestimo (
    transacao_id INT,
    prev_devolucao DATE NOT NULL,
    data_devolucao DATE,
    update_date DATE, -- Gabriel: caso a previsão de devolução mude

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 18. Tabela de Avaliações
CREATE TABLE Avaliacao (
    transacao_id INT,
    avaliador_id INT,
    avaliado_id INT,
    nota INT CHECK (nota BETWEEN 0 AND 10),
    avaliacao TEXT, -- Gabriel: pode ser nula?

    PRIMARY KEY (transacao_id, avaliado_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (avaliador_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (avaliado_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- Views

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
    CASE
        WHEN a.transacao_id IS NOT NULL THEN 'Aluguel'
        WHEN d.transacao_id IS NOT NULL THEN 'Doação'
        WHEN e.transacao_id IS NOT NULL THEN 'Empréstimo'
        ELSE 'Outro'
    END AS tipo_transacao,
    COUNT(t.id_transacao) AS total_transacoes
FROM
    Transacao t
LEFT JOIN
    Aluguel a ON t.id_transacao = a.transacao_id
LEFT JOIN
    Doacao d ON t.id_transacao = d.transacao_id
LEFT JOIN
    Emprestimo e ON t.id_transacao = e.transacao_id
GROUP BY
    tipo_transacao;

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

-- Triggers

-- Transactions