// Variável global para armazenar o item carregado
let itemCarregado = null;

async function carregarDetalhes() {
    const urlParams = new URLSearchParams(window.location.search);
    const itemId = urlParams.get('id');

    if (!itemId) {
        window.location.href = 'index.html';
        return;
    }

    try {
        const resposta = await fetch(`http://localhost:3000/api/itens/${itemId}`);
        
        if (!resposta.ok) throw new Error("Item não encontrado");

        itemCarregado = await resposta.json();

        // Preenche os dados na tela (usando os IDs que adicionamos no HTML)
        document.getElementById('item-nome').innerText = itemCarregado.nome;
        document.getElementById('item-categoria').innerText = itemCarregado.categoria;
        document.getElementById('item-descricao').innerText = itemCarregado.descricao;
        document.getElementById('item-img').src = itemCarregado.imagem || 'https://via.placeholder.com/500x400';

        // Estiliza o badge de acordo com o tipo (opcional)
        const badge = document.getElementById('item-categoria');
        badge.className = `badge type-${itemCarregado.tipo?.toLowerCase()}`;

    } catch (erro) {
        console.error("Erro ao carregar item:", erro);
        document.getElementById('item-nome').innerText = "Erro ao carregar item";
    }
}

// Função ÚNICA para gerenciar o carrinho
function gerenciarCarrinho() {
    if (!itemCarregado) {
        alert("Aguarde o carregamento do item.");
        return;
    }

    // 1. Pega o que já tem no "baú" (localStorage) ou cria um array vazio
    let carrinho = JSON.parse(localStorage.getItem('ecoshare_cart')) || [];

    // 2. Adiciona o novo item
    carrinho.push(itemCarregado);

    // 3. Salva de volta no "baú" transformando em texto
    localStorage.setItem('ecoshare_cart', JSON.stringify(carrinho));

    // 4. Feedback e Redirecionamento
    alert('Item adicionado ao carrinho!');
    window.location.href = 'carrinho.html';
}

// Configura os eventos ao carregar a página
window.onload = () => {
    carregarDetalhes();

    // Configura o clique do botão "Solicitar Agora"
    const btnSolicitar = document.querySelector('.btn-primary');
    if (btnSolicitar) {
        btnSolicitar.addEventListener('click', gerenciarCarrinho);
    }
};