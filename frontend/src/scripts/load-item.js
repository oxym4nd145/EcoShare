// Variável global para armazenar os dados carregados
let itemCarregado = null;

function formatarClasse(texto) {
    if (!texto) return 'default';
    return texto
        .toLowerCase()               // 1. Tudo minúsculo
        .normalize('NFD')            // 2. Separa os acentos das letras
        .replace(/[\u0300-\u036f]/g, "") // 3. Remove os acentos
        .replace(/\s+/g, '-')        // 4. Troca ESPAÇOS por TRAÇOS
        .trim();                     // 5. Remove espaços extras nas pontas
}

async function carregarDetalhes() {
    const urlParams = new URLSearchParams(window.location.search);
    const itemId = urlParams.get('id');

    try {
        // Dispara as 3 rotas simultaneamente
        const [resItem, resAvaliacoes, resManutencao] = await Promise.all([
            fetch(`http://localhost:3000/api/itens/${itemId}`),
            fetch(`http://localhost:3000/api/itens/${itemId}/avaliacoes`),
            fetch(`http://localhost:3000/api/itens/${itemId}/manutencao`)
        ]);

        const item = await resItem.json();
        itemCarregado = item;
        const avaliacoes = await resAvaliacoes.json();
        const manutencoes = await resManutencao.json();

        // Preenche o HTML (Exemplo)
        document.getElementById('item-nome').innerText = item.nome;
        document.getElementById('item-dono').innerText = item.dono;
        document.getElementById('item-categoria').innerText = item.categoria;
        document.getElementById('item-estado').innerText = item.estado;
        document.getElementById('item-descricao').innerText = item.descricao;
        document.getElementById('item-localizacao').innerText = item.localizacao;
        const dispElement = document.getElementById('item-disponibilidade');
        if (dispElement && item.tipo) {
            dispElement.innerText = item.tipo;
            const classeTipo = formatarClasse(item.tipo);
            dispElement.className = `badge badge-outline type-${classeTipo}`;
        }
        
        const btnChat = document.querySelector('.btn-chat');

        btnChat.addEventListener('click', (e) => {
            e.preventDefault();

            if (!itemCarregado || !itemCarregado.dono_id) {
                console.error("Erro: dono_id não está no objeto", itemCarregado);
                alert("Erro ao identificar o dono do item. Tente atualizar a página.");
                return;
            }

            const params = new URLSearchParams({
                item: itemCarregado._id, 
                dono: itemCarregado.dono_id 
            });

            window.location.href = `mensagens.html?${params.toString()}`;
        });

        // ===== Lógica dos Botões Editar e Deletar =====
        const usuarioId = localStorage.getItem('usuario_id');
        const btnEditar = document.getElementById('btn-editar');
        const btnDeletar = document.getElementById('btn-deletar');

        // Se o item é do usuário logado, mostra os botões
        if (usuarioId && itemCarregado.dono_id === Number(usuarioId)) {
            // Botão Editar
            if (btnEditar) {
                btnEditar.style.display = 'inline-flex';
                btnEditar.addEventListener('click', () => {
                    window.location.href = `edit-item.html?id=${itemCarregado._id}`;
                });
            }

            // Botão Deletar
            if (btnDeletar) {
                btnDeletar.style.display = 'inline-flex';
                btnDeletar.addEventListener('click', async () => {
                    if (confirm(`Tem certeza que deseja deletar "${itemCarregado.nome}"?`)) {
                        await deletarItemAtual();
                    }
                });
            }
        } else {
            // Esconder botões se o item não é do usuário
            if (btnEditar) btnEditar.style.display = 'none';
            if (btnDeletar) btnDeletar.style.display = 'none';
        }

        renderizarAvaliacoes(avaliacoes);
        renderizarManutencoes(manutencoes);

    } catch (erro) {
        console.error("Erro na carga paralela:", erro);
    }
}

function renderizarAvaliacoes(avaliacoes) {
    const container = document.getElementById('lista-avaliacoes');
    if (!container) return;

    if (avaliacoes.length === 0) {
        container.innerHTML = "<p class='empty-msg'>Este item ainda não possui avaliações.</p>";
        return;
    }

    container.innerHTML = avaliacoes.map(av => `
        <div class="review-card">
            <div class="review-header">
                <strong>${av.nome_usuario}</strong>
                <span class="stars">
                    ${'★'.repeat((av.nota / 2) | 0)}${'⯨'.repeat(av.nota % 2)}${'☆'.repeat(5 - ((av.nota / 2) | 0) - (av.nota % 2))}
                </span>
                <!-- <span class="stars">${'★'.repeat((av.nota/2))}${'☆'.repeat(5 - av.nota/2)}</span> -->
            </div>
            <p class="review-comment">${av.comentario || "Sem comentário"}</p>
            <small class="review-date">${av.data ? new Date(av.data).toLocaleDateString('pt-BR') : ''}</small>
        </div>
    `).join('');
}

function renderizarManutencoes(manutencoes) {
    const tbody = document.getElementById('lista-manutencao');
    if (!tbody) return;

    if (manutencoes.length === 0) {
        tbody.innerHTML = "<tr><td colspan='3'>Nenhum registro de manutenção encontrado.</td></tr>";
        return;
    }

    tbody.innerHTML = manutencoes.map(m => `
        <tr>
            <td>${new Date(m.data_inicio).toLocaleDateString('pt-BR')}</td>
            <td>Manutenção Periódica</td>
            <td>
                <span class="status-pill ${m.data_fim ? 'finished' : 'ongoing'}">
                    ${m.data_fim ? 'Concluída' : 'Em Aberto'}
                </span>
            </td>
        </tr>
    `).join('');
}

function gerenciarCarrinho() {
    if (!itemCarregado) {
        alert("Aguarde o carregamento dos dados.");
        return;
    }

    // Verificamos se o texto do status é diferente de "Disponível"
    if (itemCarregado.tipo !== 'Disponível') {
        alert("Desculpe, este item não está disponível para solicitação no momento.");
        return;
    }

    const userLogado = localStorage.getItem('usuario_id');
    console.log(userLogado);
    console.log(itemCarregado.dono_id);
    if (userLogado && itemCarregado.dono_id === Number(userLogado)) {
        alert('Você é o dono deste item.');
        return;
    }

    let carrinho = JSON.parse(localStorage.getItem('ecoshare_cart')) || [];
    
    const jaExiste = carrinho.find(i => i._id === itemCarregado._id);
    
    if (!jaExiste) {
        carrinho.push(itemCarregado);
        localStorage.setItem('ecoshare_cart', JSON.stringify(carrinho));
        alert('Item adicionado ao seu carrinho!');
        window.location.href = 'carrinho.html';
    } else {
        alert('Este item já está no seu carrinho.');
    }
}

document.addEventListener('DOMContentLoaded', () => {
    carregarDetalhes();
    const btnSolicitar = document.getElementById('btn-solicitar');
    if (btnSolicitar) {
        btnSolicitar.addEventListener('click', gerenciarCarrinho);
    }
});

async function deletarItemAtual() {
    if (!itemCarregado) {
        alert('Erro ao carregar dados do item.');
        return;
    }

    if (!confirm(`Tem certeza que deseja deletar "${itemCarregado.nome}"?\nEsta ação não pode ser desfeita.`)) {
        return;
    }

    const usuarioId = localStorage.getItem('usuario_id');
    if (!usuarioId) {
        alert('Você precisa estar logado.');
        return;
    }

    try {
        const resposta = await fetch(`http://localhost:3000/api/itens/${itemCarregado._id}`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ usuario_id: usuarioId })
        });

        if (!resposta.ok) {
            const erro = await resposta.json();
            throw new Error(erro.error || 'Erro ao deletar');
        }

        alert('Item deletado com sucesso!');
        window.location.href = 'perfil.html';
    } catch (erro) {
        console.error('Erro:', erro);
        alert('Erro: ' + erro.message);
    }
}