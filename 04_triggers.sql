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

-- Integridade da Avaliação
CREATE TRIGGER trg_valida_avaliador
BEFORE INSERT ON Avaliacao
FOR EACH ROW
BEGIN
    DECLARE v_comprador_id INT;

    SELECT comprador_id INTO v_comprador_id
    FROM Transacao
    WHERE id_transacao = NEW.transacao_id;

    -- Verifica se quem está tentando avaliar é o comprador real da transação
    IF NEW.avaliador_id != v_comprador_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: Apenas o comprador da transação pode realizar esta avaliação.';
    END IF;
END;
//

-- Validação de idade do usuário
CREATE TRIGGER trg_valida_idade_usuario
BEFORE INSERT ON Usuario
FOR EACH ROW
BEGIN
    DECLARE idade INT;
    SET idade = TIMESTAMPDIFF(YEAR, NEW.data_nascimento, CURDATE());
    
    IF idade < 18 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: Usuário deve ter pelo menos 18 anos.';
    END IF;
END;
//

DELIMITER ;