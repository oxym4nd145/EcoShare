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

-- Validação de idade do usuário (apenas se data_nascimento for um atributo de PF) - NA APRESENTAÇÃO!
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