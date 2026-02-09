// Variável global para armazenar os dados carregados
let itemDadosCompletos = null;

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
    console.log(itemId);

    try {
        // Dispara as 3 rotas simultaneamente
        const [resItem, resAvaliacoes, resManutencao] = await Promise.all([
            fetch(`http://localhost:3000/api/itens/${itemId}`),
            fetch(`http://localhost:3000/api/itens/${itemId}/avaliacoes`),
            fetch(`http://localhost:3000/api/itens/${itemId}/manutencao`)
        ]);

        const item = await resItem.json();
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
        
        renderizarAvaliacoes(avaliacoes);
        renderizarManutencoes(manutencoes);

    } catch (erro) {
        console.error("Erro na carga paralela:", erro);
    }
}

function renderizarAvaliacoes(avaliacoes) {
    console.log(avaliacoes);
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
    if (!itemDadosCompletos) {
        alert("Aguarde o carregamento dos dados.");
        return;
    }

    let carrinho = JSON.parse(localStorage.getItem('ecoshare_cart')) || [];
    
    // O ID no seu SQL unificado é retornado como _id
    const jaExiste = carrinho.find(i => i._id === itemDadosCompletos._id);
    
    if (!jaExiste) {
        carrinho.push(itemDadosCompletos);
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