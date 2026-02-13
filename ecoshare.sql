-- Criação do Banco de Dados
CREATE DATABASE ECOSHARE;
USE ECOSHARE;

-- 1. Tabela de ID universal de objeto como alvo de denúncia
CREATE TABLE Alvo_ID (
    id_alvo INT AUTO_INCREMENT,
    tipo_objeto VARCHAR(40) NOT NULL,

    PRIMARY KEY (id_alvo)
);

-- 2. Tabela de Tipos de Mensalidade
CREATE TABLE Mensalidade_tipo (
    id_mensalidade INT AUTO_INCREMENT,
    tipo_mensalidade VARCHAR(50) NOT NULL UNIQUE, -- Sem mensalidade, básica, plus

    PRIMARY KEY (id_mensalidade)
);

-- 3. Tabela de Permissões (RBAC)
CREATE TABLE Permissao (
    id_permissao INT,
    nome_permissao VARCHAR(40),

    PRIMARY KEY (id_permissao)
);

-- 4. Tabela de Fotos
CREATE TABLE Foto (
    id_foto INT AUTO_INCREMENT,
    endereco_cdn VARCHAR(255) NOT NULL,

    PRIMARY KEY (id_foto)
);

-- 5. Tabela de Endereços
CREATE TABLE Endereco (
    id_endereco INT AUTO_INCREMENT,
    cep CHAR(9) NOT NULL,
    logradouro VARCHAR(255) NOT NULL,
    numero VARCHAR(10),
    complemento VARCHAR(255),
    bairro VARCHAR(255) NOT NULL,
    cidade VARCHAR(255) NOT NULL,
    estado CHAR(2) NOT NULL,

    PRIMARY KEY (id_endereco)
);

-- 6. Tabela de CPF e CNPJ
CREATE TABLE TipoPessoa (
    id_tipo_pessoa INT,
    tipo CHAR(2) NOT NULL UNIQUE, -- PF/PJ
    nome_tipo VARCHAR(50) NOT NULL UNIQUE,

    PRIMARY KEY (id_tipo_pessoa)
);

-- 7. Tabela de Usuários
CREATE TABLE Usuario (
    id_usuario INT AUTO_INCREMENT,
    mensalidade_id INT NOT NULL,
    nivel_permissao INT NOT NULL,
    foto_perfil_id INT,
    nome_usuario VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    tipo_pessoa INT NOT NULL,
    hash_senha VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    saldo DECIMAL(10, 2) DEFAULT 0.00,
    endereco_id INT,

    alvo_id INT NOT NULL UNIQUE, -- Para denúncias

    PRIMARY KEY (id_usuario),

    FOREIGN KEY (mensalidade_id) REFERENCES Mensalidade_tipo(id_mensalidade)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (nivel_permissao) REFERENCES Permissao(id_permissao)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (foto_perfil_id) REFERENCES Foto(id_foto)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (tipo_pessoa) REFERENCES TipoPessoa(id_tipo_pessoa)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (endereco_id) REFERENCES Endereco(id_endereco)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (alvo_id) REFERENCES Alvo_ID(id_alvo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 8. Tabela de CPF 
CREATE TABLE Cpf (
    usuario_id INT,
    cpf CHAR(11) NOT NULL UNIQUE,

    PRIMARY KEY (usuario_id),

    FOREIGN KEY (usuario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 9. Tabela de CNPJ
CREATE TABLE Cnpj (
    usuario_id INT,
    cnpj CHAR(14) NOT NULL UNIQUE,

    PRIMARY KEY (usuario_id),

    FOREIGN KEY (usuario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 10. Tabela de Categorias de Itens
CREATE TABLE Categoria_tipo (
    id_categoria INT AUTO_INCREMENT,
    tipo_categoria VARCHAR(50) NOT NULL UNIQUE, -- Ferramentas, eletrônicos, etc.

    PRIMARY KEY (id_categoria)
);

-- 11. Tabela de Estados de Conservação
CREATE TABLE Estado_tipo (
    id_estado INT AUTO_INCREMENT,
    tipo_estado VARCHAR(50) NOT NULL UNIQUE, -- Novo, usado, seminovo

    PRIMARY KEY (id_estado)
);

-- 12. Tabela de Disponibilidades de Itens
CREATE TABLE Status_tipo (
    id_status INT AUTO_INCREMENT,
    tipo_status VARCHAR(50) NOT NULL UNIQUE, -- Disponível, Não disponível (doado), Em uso (emprestado/alugado), Em manutenção

    PRIMARY KEY (id_status)
);

-- 13. Tabela de Itens
CREATE TABLE Item (
    id_item INT AUTO_INCREMENT,
    dono_id INT,
    nome_item VARCHAR(100) NOT NULL,
    categoria INT NOT NULL,
    status_item INT NOT NULL, 
    descricao TEXT,
    estado_conservacao INT NOT NULL,

    alvo_id INT NOT NULL UNIQUE, -- Para denúncias

    PRIMARY KEY (id_item),

    FOREIGN KEY (categoria) REFERENCES Categoria_tipo(id_categoria)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (dono_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (status_item) REFERENCES Status_tipo(id_status)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (estado_conservacao) REFERENCES Estado_tipo(id_estado)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (alvo_id) REFERENCES Alvo_ID(id_alvo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 14. Tabela de Fotos de Itens
CREATE TABLE Foto_item (
    foto_id INT,
    item_id INT,

    PRIMARY KEY (foto_id, item_id),

    FOREIGN KEY (foto_id) REFERENCES Foto(id_foto)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 15. Tabela de Manutenção
CREATE TABLE Manutencao (
    id_manutencao INT AUTO_INCREMENT,
    item_id INT NOT NULL,
    data_inicio_manutencao DATE NOT NULL,
    data_fim_manutencao DATE,

    PRIMARY KEY (id_manutencao),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 16. Tabela de Mensagens (Chat)
CREATE TABLE Mensagem (
    hash_mensagem CHAR(36), -- UUID
    item_id INT NOT NULL,
    remetente_id INT,
    destinatario_id INT,
    texto_mensagem TEXT NOT NULL,
    horario_mensagem TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    alvo_id INT NOT NULL UNIQUE, -- Para denúncias

    PRIMARY KEY (hash_mensagem),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (remetente_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (destinatario_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (alvo_id) REFERENCES Alvo_ID(id_alvo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 17. Tabela de Pontos de Coleta
CREATE TABLE Ponto_coleta (
    id_coleta INT AUTO_INCREMENT,
    nome_coleta VARCHAR(100) NOT NULL UNIQUE,
    endereco_coleta INT NOT NULL,

    PRIMARY KEY (id_coleta),

    FOREIGN KEY (endereco_coleta) REFERENCES Endereco(id_endereco)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

-- 18. Tabela de Tipos de Transação
CREATE TABLE Transacao_tipo (
    id_transacao_tipo INT,
    tipo_transacao VARCHAR(40) NOT NULL UNIQUE,

    PRIMARY KEY (id_transacao_tipo)
);

-- 19. Tabela de Transações
CREATE TABLE Transacao (
    id_transacao INT AUTO_INCREMENT,
    item_id INT NOT NULL,
    comprador_id INT,
    coleta_id INT,
    tipo_transacao INT NOT NULL,
    data_transacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_coleta TIMESTAMP,

    alvo_id INT NOT NULL UNIQUE, -- Para denúncias

    PRIMARY KEY (id_transacao),

    FOREIGN KEY (item_id) REFERENCES Item(id_item)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (comprador_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (coleta_id) REFERENCES Ponto_coleta(id_coleta)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (tipo_transacao) REFERENCES Transacao_tipo(id_transacao_tipo)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (alvo_id) REFERENCES Alvo_ID(id_alvo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 20. Tabela de Transações de Aluguel
CREATE TABLE Aluguel (
    transacao_id INT,
    prev_devolucao DATE NOT NULL,
    update_date DATE,
    data_devolucao DATE,
    preco DECIMAL(10, 2) NOT NULL,
    multa DECIMAL(10, 2), -- Gabriel: regra de negócio ctz

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 21. Tabela de Transações de Empréstimo
CREATE TABLE Emprestimo (
    transacao_id INT,
    prev_devolucao DATE NOT NULL,
    update_date DATE, -- Gabriel: caso a previsão de devolução mude
    data_devolucao DATE,

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 22. Tabela de Transações de Venda
CREATE TABLE Venda (
    transacao_id INT,
    preco DECIMAL(10, 2) NOT NULL,

    PRIMARY KEY (transacao_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 23. Tabela de Avaliações
CREATE TABLE Avaliacao (
    transacao_id INT,
    avaliador_id INT,
    avaliado_id INT,
    nota INT CHECK (nota BETWEEN 0 AND 10),
    avaliacao TEXT, -- Gabriel: pode ser nula?

    alvo_id INT NOT NULL UNIQUE, -- Para denúncias

    PRIMARY KEY (transacao_id, avaliado_id),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (avaliador_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL,

    FOREIGN KEY (avaliado_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (alvo_id) REFERENCES Alvo_ID(id_alvo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- 24. Tabela de Métodos de Pagamento
CREATE TABLE Metodo_pagamento_tipo (
    id_metodo_pagamento INT,
    nome_metodo_pagamento VARCHAR(40) NOT NULL UNIQUE,

    PRIMARY KEY (id_metodo_pagamento)
);

-- 25. Tabela de Status de Pagamento
CREATE TABLE Status_pagamento_tipo (
    id_status_pagamento INT,
    nome_status_pagamento VARCHAR(40) NOT NULL UNIQUE,

    PRIMARY KEY (id_status_pagamento)
);

-- 26. Tabela de Pagamentos
CREATE TABLE Pagamento (
    id_pagamento INT AUTO_INCREMENT,
    transacao_id INT NOT NULL,
    metodo_pagamento INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    status_pagamento INT,
    data_pagamento TIMESTAMP,
    id_gateway_externo VARCHAR(100),

    PRIMARY KEY (id_pagamento),

    FOREIGN KEY (transacao_id) REFERENCES Transacao(id_transacao)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (metodo_pagamento) REFERENCES Metodo_pagamento_tipo(id_metodo_pagamento)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (status_pagamento) REFERENCES Status_pagamento_tipo(id_status_pagamento)
        ON UPDATE CASCADE ON DELETE NO ACTION
);

-- 27. Tabela de Estados de Denúncia
CREATE TABLE Denuncia_estado (
    id_denuncia_estado INT,
    denuncia_estado VARCHAR(40),

    PRIMARY KEY (id_denuncia_estado)
);

-- 28. Tabela de Denúncias
CREATE TABLE Denuncia (
    id_denuncia INT AUTO_INCREMENT,
    denuncia_denunciador_id INT NOT NULL,
    denuncia_alvo_id INT NOT NULL,
    denuncia_conteudo TINYTEXT NOT NULL,
    denuncia_data DATE NOT NULL,
    denuncia_estado INT NOT NULL,
    denuncia_responsavel INT,

    PRIMARY KEY (id_denuncia),

    FOREIGN KEY (denuncia_denunciador_id) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE CASCADE,

    FOREIGN KEY (denuncia_alvo_id) REFERENCES Alvo_ID(id_alvo)
        ON UPDATE CASCADE ON DELETE CASCADE,
   
    FOREIGN KEY (denuncia_estado) REFERENCES Denuncia_estado(id_denuncia_estado)
        ON UPDATE CASCADE ON DELETE NO ACTION,

    FOREIGN KEY (denuncia_responsavel) REFERENCES Usuario(id_usuario)
        ON UPDATE CASCADE ON DELETE SET NULL
);

-- Povoamento de tabelas auxiliares

INSERT INTO Mensalidade_tipo (id_mensalidade, tipo_mensalidade) VALUES
(1, 'Sem mensalidade'),
(2, 'Básica'),
(3, 'Plus');

INSERT INTO TipoPessoa (id_tipo_pessoa, tipo, nome_tipo) VALUES 
(1, 'PF', 'Pessoa Física'),
(2, 'PJ', 'Pessoa Jurídica');

INSERT INTO Permissao (id_permissao, nome_permissao) VALUES
(1, 'Conta inativa'),
(2, 'Conta ativa'),
(3,'Conta de moderação'),
(4,'Conta de administração'),
(5,'Conta banida');

INSERT INTO Estado_tipo (id_estado, tipo_estado) VALUES
(1, 'Novo'),
(2, 'Seminovo'),
(3, 'Usado');

INSERT INTO Status_tipo (id_status, tipo_status) VALUES
(1, 'Disponível'),
(2, 'Indisponível'),
(3, 'Em uso'),
(4, 'Em manutenção');

INSERT INTO Categoria_tipo (tipo_categoria) VALUES
('Ferramentas'),
('Eletrônicos'),
('Livros'),
('Esportes'),
('Móveis'),
('Eletrodomésticos'),
('Jardim'),
('Música'),
('Brinquedos'),
('Roupas'),
('Automotivo'),
('Informática'),
('Cozinha'),
('Decoração'),
('Instrumentos Musicais'),
('Filmes e Séries'),
('Jogos'),
('Camping'),
('Fotografia'),
('Artesanato');

INSERT INTO Metodo_pagamento_tipo (id_metodo_pagamento, nome_metodo_pagamento) VALUES
(1, 'Cartão de Crédito'),
(2, 'Cartão de Débito'),
(3, 'Boleto Bancário'),
(4, 'Pix'),
(5, 'Transferência Bancária');

INSERT INTO Status_pagamento_tipo (id_status_pagamento, nome_status_pagamento) VALUES
(1, 'Pendente'),
(2, 'Pago'),
(3, 'Cancelado'),
(4, 'Reembolsado');

INSERT INTO Denuncia_estado (id_denuncia_estado, denuncia_estado) VALUES
(1, 'Aberta'),
(2, 'Tramitando'),
(3, 'Cancelada - errada'),
(4, 'Cancelada - falsa'),
(0, 'Fechada');

INSERT INTO Transacao_tipo (id_transacao_tipo, tipo_transacao) VALUES
(1, 'Doação'),
(2, 'Aluguel'),
(3, 'Empréstimo'),
(4, 'Venda');

-- Criação de Views

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
    c.tipo_categoria AS 'Categoria',
    COUNT(*) AS 'Total de Itens',
    SUM(s.tipo_status = 'Disponível') AS 'Itens Disponíveis',
    SUM(s.tipo_status = 'Indisponível') AS 'Itens Indisponíveis',
    SUM(s.tipo_status = 'Em Uso') AS 'Itens em Uso',
    SUM(s.tipo_status = 'Em Manutenção') AS 'Itens em Manutenção'
FROM 
    Item i
JOIN 
    Categoria_tipo c ON i.categoria = c.id_categoria
JOIN 
    Status_tipo s ON i.status_item = s.id_status
GROUP BY 
    c.tipo_categoria;

-- 6. View de Itens em Manutenção
CREATE VIEW Item_em_manutencao AS
SELECT
    i.id_item AS 'ID do Item',
    i.nome_item AS 'Nome do Item',
    u.nome_usuario AS 'Dono do Item',
    c.tipo_categoria AS 'Categoria',
    i.descricao AS 'Descrição',
    e.tipo_estado AS 'Estado de Conservação',
    m.data_inicio_manutencao AS 'Data de Entrada em Manutenção',
    m.data_fim_manutencao AS 'Data de Saída da Manutenção'
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

-- 7. View de Itens por Estado de Conservação
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

-- 8. View de Itens por Usuário
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

-- 9. View de Transações por Tipo
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

-- 10. View de Transações e Pagamentos
CREATE VIEW Transacao_pagamento AS
SELECT
    tt.tipo_transacao AS 'Tipo de Transação',
    i.nome_item AS 'Nome do Item',
    uc.nome_usuario AS 'Comprador',
    uv.nome_usuario AS 'Dono do Item',
    t.data_transacao AS 'Data da Transação',
    mp.nome_metodo_pagamento AS 'Método de Pagamento',
    sp.nome_status_pagamento AS 'Status do Pagamento',
    p.valor AS 'Valor da Transação',
    p.data_pagamento AS 'Data do Pagamento'
FROM 
    Transacao t
JOIN 
    Transacao_tipo tt ON t.tipo_transacao = tt.id_transacao_tipo
JOIN 
    Item i ON t.item_id = i.id_item
JOIN 
    Usuario uv ON i.dono_id = uv.id_usuario
LEFT JOIN 
    Usuario uc ON t.comprador_id = uc.id_usuario
LEFT JOIN 
    Pagamento p ON p.transacao_id = t.id_transacao
LEFT JOIN 
    Metodo_pagamento_tipo mp ON p.metodo_pagamento = mp.id_metodo_pagamento
LEFT JOIN 
    Status_pagamento_tipo sp ON p.status_pagamento = sp.id_status_pagamento;

-- 11. View de Itens mais Populares (mais transacionados)
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

-- 12. Denuncias mais recentes
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

-- 13. Denúncias mais antigas ainda em aberto 
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

-- 14. Contagem de denúncias por estado
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
    de.denuncia_estado;

-- Criação de triggers

DELIMITER //

-- Ao iniciar manutenção -> Muda item para 4 (Em manutenção)
CREATE TRIGGER trg_inicio_manutencao
AFTER INSERT ON Manutencao
FOR EACH ROW
BEGIN
    -- Verifica se data_fim_manutencao está NULL antes de mudar o status
    IF NEW.data_fim_manutencao IS NULL THEN
        UPDATE Item
        SET status_item = 4
        WHERE id_item = NEW.item_id;
    END IF;
END;
//

-- Ao finalizar manutenção (data_fim preenchida) -> Muda item para 1 (Disponível)
CREATE TRIGGER trg_fim_manutencao
AFTER UPDATE ON Manutencao
FOR EACH ROW
BEGIN
    IF OLD.data_fim_manutencao IS NULL AND NEW.data_fim_manutencao IS NOT NULL THEN
        UPDATE Item
        SET status_item = 1
        WHERE id_item = NEW.item_id;
    END IF;
END;
//

-- Valida disponibilidade e impede autonegociação
CREATE TRIGGER trg_valida_transacao
BEFORE INSERT ON Transacao
FOR EACH ROW
BEGIN
    DECLARE estado_atual INT;
    DECLARE id_dono INT;
    
    SELECT status_item, dono_id INTO estado_atual, id_dono 
    FROM Item 
    WHERE id_item = NEW.item_id;
    
    -- Verifica se o item está Disponível (1)
    IF estado_atual != 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Operação negada: Item indisponível.';
    END IF;

    -- Impede que o dono compre/alugue de si mesmo
    IF id_dono = NEW.comprador_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: Proprietário não pode transacionar o próprio item.';
    END IF;
END;
//

-- Atualiza estado após confirmação de DOAÇÂO
CREATE TRIGGER trg_pos_transacao
AFTER INSERT ON Transacao
FOR EACH ROW
BEGIN
    -- Como Doação não tem tabela filha, atualizamos a disponibilidade aqui
    -- Doação (1) -> Indisponível (2)
    IF NEW.tipo_transacao = 1 THEN
        SET @skip_trg_item_update_5dias = 1;
        UPDATE Item SET status_item = 2 WHERE id_item = NEW.item_id;
        SET @skip_trg_item_update_5dias = NULL;
    END IF;
END;
//

-- Atualiza estado após confirmação de VENDA
CREATE TRIGGER trg_detalhe_venda
AFTER INSERT ON Venda
FOR EACH ROW
BEGIN
    SET @skip_trg_item_update_5dias = 1;
    UPDATE Item 
    SET status_item = 2 
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
    SET @skip_trg_item_update_5dias = NULL;
END;
//

-- Atualiza estado após confirmação de ALUGUEL
CREATE TRIGGER trg_detalhe_aluguel AFTER INSERT ON Aluguel FOR EACH ROW
BEGIN
    SET @skip_trg_item_update_5dias = 1;
    UPDATE Item SET status_item = 3
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
    SET @skip_trg_item_update_5dias = NULL;
END;
//

-- Atualiza estado após confirmação de EMPRÉSTIMO
CREATE TRIGGER trg_detalhe_emprestimo AFTER INSERT ON Emprestimo FOR EACH ROW
BEGIN
    SET @skip_trg_item_update_5dias = 1;
    UPDATE Item SET status_item = 3
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
    SET @skip_trg_item_update_5dias = NULL;
END;
//

-- Alteração do status após devolução de ALUGUEL
CREATE TRIGGER trg_devolucao_aluguel
AFTER UPDATE ON Aluguel
FOR EACH ROW
BEGIN
    IF OLD.data_devolucao IS NULL AND NEW.data_devolucao IS NOT NULL THEN
        SET @skip_trg_item_update_5dias = 1;
        UPDATE Item i
        JOIN Transacao t ON i.id_item = t.item_id
        SET i.status_item = 1
        WHERE t.id_transacao = NEW.transacao_id;
        SET @skip_trg_item_update_5dias = NULL;
    END IF;
END;
//

-- Alteração do status após devolução de EMPRÉSTIMO
CREATE TRIGGER trg_devolucao_emprestimo
AFTER UPDATE ON Emprestimo
FOR EACH ROW
BEGIN
    IF OLD.data_devolucao IS NULL AND NEW.data_devolucao IS NOT NULL THEN
        SET @skip_trg_item_update_5dias = 1;
        UPDATE Item i
        JOIN Transacao t ON i.id_item = t.item_id
        SET i.status_item = 1
        WHERE t.id_transacao = NEW.transacao_id;
        SET @skip_trg_item_update_5dias = NULL;
    END IF;
END;
//

-- Atualiza o saldo automaticamente
CREATE TRIGGER trg_atualiza_saldo_vendedor
AFTER UPDATE ON Pagamento
FOR EACH ROW
BEGIN
    DECLARE v_dono_id INT;

    -- Verifica se o status mudou para 'Pago' (2)
    IF OLD.status_pagamento != 2 AND NEW.status_pagamento = 2 THEN
        -- Localiza o dono do item através da transação
        SELECT i.dono_id INTO v_dono_id
        FROM Transacao t
        JOIN Item i ON t.item_id = i.id_item
        WHERE t.id_transacao = NEW.transacao_id;

        -- Adiciona o valor ao saldo do dono
        UPDATE Usuario
        SET saldo = saldo + NEW.valor
        WHERE id_usuario = v_dono_id;
    END IF;
END;
//

-- Validação para CPF
CREATE TRIGGER trg_valida_insercao_cpf
BEFORE INSERT ON Cpf
FOR EACH ROW
BEGIN
    DECLARE v_tipo INT;
    SELECT tipo_pessoa INTO v_tipo FROM Usuario WHERE id_usuario = NEW.usuario_id;
    
    IF v_tipo != 1 THEN -- 1 é PF
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: Usuário deve ser Pessoa Física para possuir CPF.';
    END IF;
END;
//

-- Validação para CNPJ
CREATE TRIGGER trg_valida_insercao_cnpj
BEFORE INSERT ON Cnpj
FOR EACH ROW
BEGIN
    DECLARE v_tipo INT;
    SELECT tipo_pessoa INTO v_tipo FROM Usuario WHERE id_usuario = NEW.usuario_id;
    
    IF v_tipo != 2 THEN -- 2 é PJ
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: Usuário deve ser Pessoa Jurídica para possuir CNPJ.';
    END IF;
END;
//

-- Validação para atualização do tipo de pessoa
CREATE TRIGGER trg_valida_update_tipo_pessoa
BEFORE UPDATE ON Usuario
FOR EACH ROW
BEGIN
    IF OLD.tipo_pessoa != NEW.tipo_pessoa THEN
       IF EXISTS (SELECT 1 FROM Cpf WHERE usuario_id = NEW.id_usuario) THEN
            SIGNAL SQLSTATE '45000'
           SET MESSAGE_TEXT = 'Erro: Não é possível alterar tipo de pessoa com CPF associado.';
        END IF;
        
        IF EXISTS (SELECT 1 FROM Cnpj WHERE usuario_id = NEW.id_usuario) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erro: Não é possível alterar tipo de pessoa com CNPJ associado.';
        END IF;
    END IF;
 END;
//

-- Adição de ID de alvo a mensagens
CREATE TRIGGER add_id_alvo_msg
BEFORE INSERT ON Mensagem
FOR EACH ROW
BEGIN
    INSERT INTO Alvo_ID (tipo_objeto) VALUES ('Mensagem');
    SET NEW.alvo_id = LAST_INSERT_ID();
END; 
//

-- Adição de ID de alvo a avaliações
CREATE TRIGGER add_id_alvo_aval
BEFORE INSERT ON Avaliacao
FOR EACH ROW
BEGIN
    INSERT INTO Alvo_ID (tipo_objeto) VALUES ('Avaliação');
    SET NEW.alvo_id = LAST_INSERT_ID();
END;
//

-- Adição de ID de alvo a transações
CREATE TRIGGER add_id_alvo_trsc
BEFORE INSERT ON Transacao
FOR EACH ROW
BEGIN
    INSERT INTO Alvo_ID (tipo_objeto) VALUES ('Transação');
    SET NEW.alvo_id = LAST_INSERT_ID();
END;
//

-- Adição de ID de alvo a itens
CREATE TRIGGER add_id_alvo_item
BEFORE INSERT ON Item
FOR EACH ROW
BEGIN
    INSERT INTO Alvo_ID (tipo_objeto) VALUES ('Item');
    SET NEW.alvo_id = LAST_INSERT_ID();
END;
//

-- Adição de ID de alvo a usuários
CREATE TRIGGER add_id_alvo_user
BEFORE INSERT ON Usuario
FOR EACH ROW
BEGIN
    INSERT INTO Alvo_ID (tipo_objeto) VALUES ('Usuário');
    SET NEW.alvo_id = LAST_INSERT_ID();
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a um item
CREATE TRIGGER trg_item_delete
BEFORE DELETE ON Item
FOR EACH ROW
BEGIN
    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a um usuário
CREATE TRIGGER trg_usuario_delete
BEFORE DELETE ON Usuario
FOR EACH ROW
BEGIN
    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a uma mensagem
CREATE TRIGGER trg_mensagem_delete
BEFORE DELETE ON Mensagem
FOR EACH ROW
BEGIN
    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a uma transação
CREATE TRIGGER trg_transacao_delete
BEFORE DELETE ON Transacao
FOR EACH ROW
BEGIN
    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a uma avaliação
CREATE TRIGGER trg_avaliacao_delete
BEFORE DELETE ON Avaliacao
FOR EACH ROW
BEGIN
    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger para impedir exclusão de alvo com denúncias ativas
CREATE TRIGGER trg_alvo_delete
BEFORE DELETE ON Alvo_ID
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Denuncia
        WHERE denuncia_alvo_id = OLD.id_alvo
          AND denuncia_estado IN (1,2)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Objeto possui denúncia ativa.';
    END IF;
END;
//

-- Trigger para impedir deleção de item se a última transação dele tiver menos que 90 dias
CREATE TRIGGER trg_item_delete_90dias
BEFORE DELETE ON Item
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Transacao
        WHERE item_id = OLD.id_item
          AND DATEDIFF(CURDATE(), data_transacao) < 90
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Item possui transação recente (menos de 90 dias).';
    END IF;
END;
//

-- Triggers para impedir deleção de usuário se a última transação dele, seja como vendedor ou comprador, tiver menos que 90 dias
CREATE TRIGGER trg_usuario_delete_90dias_comprador
BEFORE DELETE ON Usuario
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Transacao
        WHERE comprador_id = OLD.id_usuario
          AND DATEDIFF(CURDATE(), data_transacao) < 90
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário possui transação recente (menos de 90 dias).';
    END IF;
END;
//

CREATE TRIGGER trg_usuario_delete_90dias_vendedor
BEFORE DELETE ON Usuario
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Transacao t
        JOIN Item i ON t.item_id = i.id_item
        WHERE i.dono_id = OLD.id_usuario
          AND DATEDIFF(CURDATE(), t.data_transacao) < 90
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário possui transação recente (menos de 90 dias).';
    END IF;
END;
//

-- Triggers para impedir atualização de item ou usuário se a última transação tiver menos que 5 dias
CREATE TRIGGER trg_item_update_5dias
BEFORE UPDATE ON Item
FOR EACH ROW
BEGIN
    IF @skip_trg_item_update_5dias IS NULL THEN
        IF EXISTS(
            SELECT 1
            FROM Transacao
            WHERE item_id = OLD.id_item
              AND DATEDIFF(CURDATE(), data_transacao) < 5
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Item possui transação recente (menos de 5 dias).';
        END IF;
    END IF;
END;
//

CREATE TRIGGER trg_usuario_update_5dias_comprador
BEFORE UPDATE ON Usuario
FOR EACH ROW
BEGIN
    IF EXISTS(
        SELECT 1
        FROM Transacao
        WHERE comprador_id = OLD.id_usuario
          AND DATEDIFF(CURDATE(), data_transacao) < 5
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário possui transação recente (menos de 5 dias).';
    END IF;
END;
//

CREATE TRIGGER trg_usuario_update_5dias_vendedor
BEFORE UPDATE ON Usuario
FOR EACH ROW
BEGIN
    IF EXISTS(
        SELECT 1
        FROM Transacao t
        JOIN Item i ON t.item_id = i.id_item
        WHERE i.dono_id = OLD.id_usuario
          AND DATEDIFF(CURDATE(), t.data_transacao) < 5
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário possui transação recente (menos de 5 dias).';
    END IF;
END;
//

DELIMITER ;

-- Criação de procedures

-- 1. Transação de criação de usuário
DELIMITER $$

CREATE PROCEDURE criar_usuario (
    IN p_nome VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_hash_senha VARCHAR(255),
    IN p_data_nascimento DATE,
    IN p_tipo_pessoa INT,
    IN p_doc VARCHAR(14),
    IN p_mensalidade INT,
    IN p_permissao INT
)
BEGIN
    DECLARE v_usuario_id INT;

    INSERT INTO Usuario (
        mensalidade_id,
        nivel_permissao,
        nome_usuario,
        email,
        tipo_pessoa,
        hash_senha,
        data_nascimento
    )
    VALUES (
        p_mensalidade,
        p_permissao,
        p_nome,
        p_email,
        p_tipo_pessoa,
        p_hash_senha,
        p_data_nascimento
    );

    SET v_usuario_id = LAST_INSERT_ID();

    IF p_tipo_pessoa = 1 THEN
        INSERT INTO Cpf(usuario_id, cpf)
        VALUES (v_usuario_id, p_doc);
    ELSE
        INSERT INTO Cnpj(usuario_id, cnpj)
        VALUES (v_usuario_id, p_doc);
    END IF;
END$$

DELIMITER ;

-- 2. Transação de criação de item
DELIMITER $$

CREATE PROCEDURE cadastrar_item (
    IN p_dono INT,
    IN p_nome VARCHAR(100),
    IN p_categoria INT,
    IN p_status INT,
    IN p_descricao TEXT,
    IN p_estado INT
)
BEGIN
    INSERT INTO Item (
        dono_id,
        nome_item,
        categoria,
        status_item,
        descricao,
        estado_conservacao
    )
    VALUES (
        p_dono,
        p_nome,
        p_categoria,
        p_status,
        p_descricao,
        p_estado
    );
END$$

DELIMITER ;

-- 3. Transação de criação de transação (compra, aluguel ou empréstimo)
DELIMITER $$

CREATE PROCEDURE criar_transacao (
    IN p_item INT,
    IN p_comprador INT,
    IN p_coleta INT,
    IN p_tipo INT,
    IN p_preco DECIMAL(10,2),
    IN p_prev_devolucao DATE,
    IN p_data_transacao TIMESTAMP,      -- novo parâmetro
    IN p_data_coleta TIMESTAMP          -- novo parâmetro
)
BEGIN
    DECLARE v_transacao_id INT;

    -- Usa CURRENT_TIMESTAMP se p_data_transacao for NULL
    IF p_data_transacao IS NULL THEN
        SET p_data_transacao = CURRENT_TIMESTAMP;
    END IF;

    INSERT INTO Transacao (
        item_id,
        comprador_id,
        coleta_id,
        tipo_transacao,
        data_transacao,
        data_coleta
    )
    VALUES (
        p_item,
        p_comprador,
        p_coleta,
        p_tipo,
        p_data_transacao,
        p_data_coleta
    );

    SET v_transacao_id = LAST_INSERT_ID();

    IF p_tipo = 4 THEN          -- Venda
        INSERT INTO Venda (transacao_id, preco)
        VALUES (v_transacao_id, p_preco);

    ELSEIF p_tipo = 3 THEN      -- Empréstimo
        INSERT INTO Emprestimo (transacao_id, prev_devolucao)
        VALUES (v_transacao_id, p_prev_devolucao);

    ELSEIF p_tipo = 2 THEN      -- Aluguel
        INSERT INTO Aluguel (transacao_id, prev_devolucao, preco)
        VALUES (v_transacao_id, p_prev_devolucao, p_preco);
    END IF;

    -- Doação (tipo 1) não insere detalhes adicionais
END$$

DELIMITER ;

-- 4. Transação de criação de pagamento
DELIMITER $$

CREATE PROCEDURE registrar_pagamento (
    IN p_transacao INT,
    IN p_metodo INT,
    IN p_valor DECIMAL(10,2),
    IN p_status INT
)
BEGIN
    INSERT INTO Pagamento (
        transacao_id,
        metodo_pagamento,
        valor,
        status_pagamento,
        data_pagamento
    )
    VALUES (
        p_transacao,
        p_metodo,
        p_valor,
        p_status,
        CURRENT_TIMESTAMP
    );
END$$

DELIMITER ;

-- 5. Transação de devolução de item
DELIMITER $$

CREATE PROCEDURE registrar_devolucao (
    IN p_transacao INT,
    IN p_data DATE
)
BEGIN
    UPDATE Emprestimo
    SET data_devolucao = p_data
    WHERE transacao_id = p_transacao;

    UPDATE Aluguel
    SET data_devolucao = p_data
    WHERE transacao_id = p_transacao;

    UPDATE Item
    SET status_item = 1
    WHERE id_item = (
        SELECT item_id FROM Transacao WHERE id_transacao = p_transacao
    );
END$$

DELIMITER ;

-- 6. Transação de abertura de denúncia
DELIMITER $$

CREATE PROCEDURE abrir_denuncia (
    IN p_denunciador INT,
    IN p_tipo_objeto VARCHAR(40),
    IN p_conteudo TINYTEXT,
    IN p_estado INT
)
BEGIN
    DECLARE v_alvo INT;

    INSERT INTO Alvo_ID(tipo_objeto)
    VALUES (p_tipo_objeto);

    SET v_alvo = LAST_INSERT_ID();

    INSERT INTO Denuncia (
        denuncia_denunciador_id,
        denuncia_alvo_id,
        denuncia_conteudo,
        denuncia_data,
        denuncia_estado
    )
    VALUES (
        p_denunciador,
        v_alvo,
        p_conteudo,
        CURRENT_DATE,
        p_estado
    );
END$$

DELIMITER ;

-- Criação de roles
DROP ROLE IF EXISTS admin, moderador, user_app;

CREATE ROLE admin;
CREATE ROLE moderador;
CREATE ROLE user_app;

-- Admin
GRANT ALL PRIVILEGES ON ECOSHARE.* TO admin;

-- Moderador
GRANT SELECT, UPDATE, DELETE ON ECOSHARE.Item TO moderador;
GRANT SELECT, UPDATE ON ECOSHARE.Usuario TO moderador;

GRANT SELECT, DELETE ON ECOSHARE.Mensagem TO moderador;
GRANT SELECT, DELETE ON ECOSHARE.Avaliacao TO moderador;
GRANT SELECT, DELETE ON ECOSHARE.Denuncia TO moderador;
GRANT SELECT, DELETE ON ECOSHARE.Foto TO moderador;
GRANT SELECT, DELETE ON ECOSHARE.Foto_item TO moderador;

GRANT SELECT ON ECOSHARE.Transacao TO moderador;
GRANT SELECT ON ECOSHARE.Aluguel TO moderador;
GRANT SELECT ON ECOSHARE.Emprestimo TO moderador;
GRANT SELECT ON ECOSHARE.Venda TO moderador;

-- Usuário
GRANT SELECT ON ECOSHARE.* TO user_app;

GRANT INSERT ON ECOSHARE.Transacao TO user_app;
GRANT INSERT ON ECOSHARE.Aluguel TO user_app;
GRANT INSERT ON ECOSHARE.Emprestimo TO user_app;
GRANT INSERT ON ECOSHARE.Venda TO user_app;

GRANT INSERT ON ECOSHARE.Mensagem TO user_app;
GRANT INSERT ON ECOSHARE.Avaliacao TO user_app;
GRANT INSERT ON ECOSHARE.Denuncia TO user_app;

GRANT UPDATE ON ECOSHARE.Item TO user_app;

-- Criação de usuários e atribuição de papéis
DROP USER IF EXISTS 'app_admin'@'localhost', 'app_mod', 'app_user';

CREATE USER 'app_admin'@'localhost' IDENTIFIED BY 'senha1';
CREATE USER 'app_mod' IDENTIFIED BY 'senha2';
CREATE USER 'app_user' IDENTIFIED BY 'senha3';

GRANT admin TO 'app_admin'@'localhost';
GRANT moderador TO 'app_mod';
GRANT user_app TO 'app_user';

SET DEFAULT ROLE admin TO 'app_admin'@'localhost';
SET DEFAULT ROLE moderador TO 'app_mod';
SET DEFAULT ROLE user_app TO 'app_user';