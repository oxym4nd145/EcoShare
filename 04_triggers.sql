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
    IF OLD.data_fim_manutencao IS NULL AND NEW.data_fim_manutencao IS NOT NULL THEN
        UPDATE Item
        SET disponibilidade = 1
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
    
    SELECT disponibilidade, dono_id INTO estado_atual, id_dono 
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
        UPDATE Item SET disponibilidade = 2 WHERE id_item = NEW.item_id;
    END IF;
END;
//

-- 5. Atualiza estado após confirmação de VENDA
CREATE TRIGGER trg_detalhe_venda
AFTER INSERT ON Venda
FOR EACH ROW
BEGIN
    UPDATE Item 
    SET disponibilidade = 2 
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
END;
//

-- 6. Atualiza estado após confirmação de ALUGUEL
CREATE TRIGGER trg_detalhe_aluguel AFTER INSERT ON Aluguel FOR EACH ROW
BEGIN
    UPDATE Item SET disponibilidade = 3
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
END;
//

-- 5. Atualiza estado após confirmação de EMPRÉSTIMO
CREATE TRIGGER trg_detalhe_emprestimo AFTER INSERT ON Emprestimo FOR EACH ROW
BEGIN
    UPDATE Item SET disponibilidade = 3
    WHERE id_item = (SELECT item_id FROM Transacao WHERE id_transacao = NEW.transacao_id);
END;
//

-- 6. Alteração do status após devolução de ALUGUEL
CREATE TRIGGER trg_devolucao_aluguel
AFTER UPDATE ON Aluguel
FOR EACH ROW
BEGIN
    IF OLD.data_devolucao IS NULL AND NEW.data_devolucao IS NOT NULL THEN
        UPDATE Item i
        JOIN Transacao t ON i.id_item = t.item_id
        SET i.disponibilidade = 1
        WHERE t.id_transacao = NEW.transacao_id;
    END IF;
END;
//

-- 8. Alteração do status após devolução de EMPRÉSTIMO
CREATE TRIGGER trg_devolucao_emprestimo
AFTER UPDATE ON Emprestimo
FOR EACH ROW
BEGIN
    IF OLD.data_devolucao IS NULL AND NEW.data_devolucao IS NOT NULL THEN
        UPDATE Item i
        JOIN Transacao t ON i.id_item = t.item_id
        SET i.disponibilidade = 1
        WHERE t.id_transacao = NEW.transacao_id;
    END IF;
END;
//

DELIMITER ;