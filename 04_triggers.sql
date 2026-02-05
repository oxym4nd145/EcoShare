DELIMITER //

-- 1. Ao iniciar manutenção -> Muda item para 4 (Em manutenção)
CREATE TRIGGER trg_inicio_manutencao
AFTER INSERT ON Manutencao
FOR EACH ROW
BEGIN
    UPDATE Item
    SET disponibilidade = 4
    WHERE id_item = NEW.item_id;
END;
//

-- 2. Ao finalizar manutenção (data_fim preenchida) -> Muda item para 1 (Disponível)
CREATE TRIGGER trg_fim_manutencao
AFTER UPDATE ON Manutencao
FOR EACH ROW
BEGIN
    -- Se a data fim foi preenchida agora
    IF OLD.data_fim_manutencao IS NULL AND NEW.data_fim_manutencao IS NOT NULL THEN
        UPDATE Item
        SET disponibilidade = 1
        WHERE id_item = NEW.item_id;
    END IF;
END;
//

-- 3. Mudança de estado ao confirmar um Aluguel (Muda item para 3 - Em uso)
CREATE TRIGGER trg_novo_aluguel
AFTER INSERT ON Aluguel
FOR EACH ROW
BEGIN
    -- Busca o item_id através da tabela pai Transacao
    UPDATE Item
    SET disponibilidade = 3
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
END;
//

-- 4. Mudança de estado ao confirmar um Empréstimo (Muda item para 3 - Em uso)
CREATE TRIGGER trg_novo_emprestimo
AFTER INSERT ON Emprestimo
FOR EACH ROW
BEGIN
    UPDATE Item
    SET disponibilidade = 3
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
END;
//

-- 5. Mudança de estado em caso de doação (Muda item para 2 - Indisponível)
CREATE TRIGGER trg_nova_doacao
AFTER INSERT ON Doacao
FOR EACH ROW
BEGIN
    UPDATE Item
    SET disponibilidade = 2
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
END;
//

-- 6. Verifica disponibilidade antes de criar Transação
CREATE TRIGGER trg_valida_disponibilidade_item
BEFORE INSERT ON Transacao
FOR EACH ROW
BEGIN
    DECLARE estado_atual INT;
    
    SELECT disponibilidade INTO estado_atual 
    FROM Item 
    WHERE id_item = NEW.item_id;
    
    -- Se NÃO for 1 (Disponível), cancela a operação
    IF estado_atual != 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Operação negada: Este item não está disponível para transação.';
    END IF;
END;
//

-- 7. Impede autonegociação
CREATE TRIGGER trg_impede_autonegociacao
BEFORE INSERT ON Transacao
FOR EACH ROW
BEGIN
    DECLARE id_dono INT;

    -- Busca o dono do item
    SELECT dono_id INTO id_dono 
    FROM Item 
    WHERE id_item = NEW.item_id;

    IF id_dono = NEW.comprador_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erro: O proprietário não pode realizar transações com seu próprio item.';
    END IF;
END;
//

-- 8. Alteração do status após devolução de ALUGUEL
CREATE TRIGGER trg_devolucao_aluguel
AFTER UPDATE ON Aluguel
FOR EACH ROW
BEGIN
    DECLARE id_do_item INT;

    -- Se a data de devolução foi preenchida
    IF OLD.data_devolucao IS NULL AND NEW.data_devolucao IS NOT NULL THEN
        
        -- Descobre o item associado à transação
        SELECT item_id INTO id_do_item 
        FROM Transacao 
        WHERE id_transacao = NEW.transacao_id;

        -- Volta a ser Disponível (1) apenas se estiver Em uso (3)
        UPDATE Item
        SET disponibilidade = 1 
        WHERE id_item = id_do_item 
        AND disponibilidade = 3;
        
    END IF;
END;
//

-- 9. Alteração do status após devolução de EMPRÉSTIMO
CREATE TRIGGER trg_devolucao_emprestimo
AFTER UPDATE ON Emprestimo
FOR EACH ROW
BEGIN
    DECLARE id_do_item INT;

    -- Se a data de devolução foi preenchida
    IF OLD.data_devolucao IS NULL AND NEW.data_devolucao IS NOT NULL THEN
        
        SELECT item_id INTO id_do_item 
        FROM Transacao 
        WHERE id_transacao = NEW.transacao_id;

        UPDATE Item
        SET disponibilidade = 1 
        WHERE id_item = id_do_item 
        AND disponibilidade = 3;
        
    END IF;
END;
//

DELIMITER ;