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