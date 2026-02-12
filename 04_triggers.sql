DELIMITER //

-- 1. Ao iniciar manutenção -> Muda item para 4 (Em manutenção)
-- MODIFICAÇÃO: Só altera status se data_fim_manutencao for NULL
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

-- 2. Ao finalizar manutenção (data_fim preenchida) -> Muda item para 1 (Disponível)
-- Este trigger já está correto
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

-- 3. Valida disponibilidade e impede autonegociação
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

-- 4. Atualiza estado após confirmação de DOAÇÂO
CREATE TRIGGER trg_pos_transacao
AFTER INSERT ON Transacao
FOR EACH ROW
BEGIN
    -- Como Doação não tem tabela filha, atualizamos a disponibilidade aqui
    -- Doação (1) -> Indisponível (2)
    IF NEW.tipo_transacao = 1 THEN
        UPDATE Item SET status_item = 2 WHERE id_item = NEW.item_id;
    END IF;
END;
//

-- 5. Atualiza estado após confirmação de VENDA
CREATE TRIGGER trg_detalhe_venda
AFTER INSERT ON Venda
FOR EACH ROW
BEGIN
    UPDATE Item 
    SET status_item = 2 
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
END;
//

-- 6. Atualiza estado após confirmação de ALUGUEL
CREATE TRIGGER trg_detalhe_aluguel AFTER INSERT ON Aluguel FOR EACH ROW
BEGIN
    UPDATE Item SET status_item = 3
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
END;
//

-- 7. Atualiza estado após confirmação de EMPRÉSTIMO
CREATE TRIGGER trg_detalhe_emprestimo AFTER INSERT ON Emprestimo FOR EACH ROW
BEGIN
    UPDATE Item SET status_item = 3
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
END;
//

-- 8. Alteração do status após devolução de ALUGUEL
CREATE TRIGGER trg_devolucao_aluguel
AFTER UPDATE ON Aluguel
FOR EACH ROW
BEGIN
    IF OLD.data_devolucao IS NULL AND NEW.data_devolucao IS NOT NULL THEN
        UPDATE Item i
        JOIN Transacao t ON i.id_item = t.item_id
        SET i.status_item = 1
        WHERE t.id_transacao = NEW.transacao_id;
    END IF;
END;
//

-- 9. Alteração do status após devolução de EMPRÉSTIMO
CREATE TRIGGER trg_devolucao_emprestimo
AFTER UPDATE ON Emprestimo
FOR EACH ROW
BEGIN
    IF OLD.data_devolucao IS NULL AND NEW.data_devolucao IS NOT NULL THEN
        UPDATE Item i
        JOIN Transacao t ON i.id_item = t.item_id
        SET i.status_item = 1
        WHERE t.id_transacao = NEW.transacao_id;
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
    
    IF v_tipo != 1 THEN -- 1 é PF conforme seu seed
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
    
    IF v_tipo != 2 THEN -- 2 é PJ conforme seu seed
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
    DECLARE tem_cpf INT;
    DECLARE tem_cnpj INT;

    IF OLD.tipo_pessoa <> NEW.tipo_pessoa THEN
        SELECT COUNT(*) INTO tem_cpf  FROM Cpf  WHERE usuario_id = NEW.id_usuario;
        SELECT COUNT(*) INTO tem_cnpj FROM Cnpj WHERE usuario_id = NEW.id_usuario;

        IF NEW.tipo_pessoa = 1 THEN
            IF tem_cnpj > 0 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Erro: Usuário PF não pode ter CNPJ.';
            END IF;
        ELSEIF NEW.tipo_pessoa = 2 THEN
            IF tem_cpf > 0 THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Erro: Usuário PJ não pode ter CPF.';
            END IF;
        END IF;
    END IF;
END;
//

-- Validação de idade do usuário (apenas se data_nascimento for um atributo de PF)
-- CREATE TRIGGER trg_valida_idade_usuario
-- BEFORE INSERT ON Usuario
-- FOR EACH ROW
-- BEGIN
--     DECLARE idade INT;
--     SET idade = TIMESTAMPDIFF(YEAR, NEW.data_nascimento, CURDATE());
    
--     IF idade < 18 THEN
--         SIGNAL SQLSTATE '45000'
--         SET MESSAGE_TEXT = 'Erro: Usuário deve ter pelo menos 18 anos.';
--     END IF;
-- END;
-- //

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
    IF EXISTS (
        SELECT 1
        FROM Denuncia
        WHERE denuncia_alvo_id = OLD.alvo_id
          AND denuncia_estado IN (1,2)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Objeto possui denúncia ativa.';
    END IF;

    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a um usuário
CREATE TRIGGER trg_usuario_delete
BEFORE DELETE ON Usuario
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Denuncia
        WHERE denuncia_alvo_id = OLD.alvo_id
          AND denuncia_estado IN (1,2)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Objeto possui denúncia ativa.';
    END IF;

    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a uma mensagem
CREATE TRIGGER trg_mensagem_delete
BEFORE DELETE ON Mensagem
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Denuncia
        WHERE denuncia_alvo_id = OLD.alvo_id
          AND denuncia_estado IN (1,2)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Objeto possui denúncia ativa.';
    END IF;

    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a uma transação
CREATE TRIGGER trg_transacao_delete
BEFORE DELETE ON Transacao
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Denuncia
        WHERE denuncia_alvo_id = OLD.alvo_id
          AND denuncia_estado IN (1,2)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Objeto possui denúncia ativa.';
    END IF;

    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

-- Trigger de delete em cascata para denúncias relacionadas a uma avaliação
CREATE TRIGGER trg_avaliacao_delete
BEFORE DELETE ON Avaliacao
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Denuncia
        WHERE denuncia_alvo_id = OLD.alvo_id
          AND denuncia_estado IN (1,2)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Objeto possui denúncia ativa.';
    END IF;

    DELETE FROM Alvo_ID
    WHERE id_alvo = OLD.alvo_id;
END;
//

DELIMITER ;