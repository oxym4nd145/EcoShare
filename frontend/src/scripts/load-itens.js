async function carregarItens() {
    const container = document.getElementById('items-container');
    
    // 1. Verifica se existe um filtro de categoria na URL da página
    const urlParams = new URLSearchParams(window.location.search);
    const categoriaId = urlParams.get('cat');

    try {
        // 2. Monta a URL da API com ou sem o filtro
        let urlApi = 'http://localhost:3000/api/itens';
        if (categoriaId) {
            urlApi += `?cat=${categoriaId}`;
        }

        const resposta = await fetch(urlApi);
        const itens = await resposta.json();

        container.innerHTML = ''; // Limpa a tela

        if (itens.length === 0) {
            container.innerHTML = '<p>Nenhum item encontrado nesta categoria.</p>';
            return;
        }

        // 3. Renderiza os itens filtrados
        itens.forEach(item => {
            const card = document.createElement('a');
            card.href = `item.html?id=${item._id}`;
            card.className = 'product-card';
            card.innerHTML = `
                <img src="${item.imagem || 'https://via.placeholder.com/250x180'}" alt="${item.nome}">
                <div class="card-info">
                    <span class="badge type-${item.tipo.toLowerCase()}">${item.tipo}</span>
                    <h3>${item.nome}</h3>
                    <p class="item-status">Estado: ${item.condicao}</p>
                </div>
            `;
            container.appendChild(card);
        });

    } catch (erro) {
        console.error("Erro ao filtrar itens:", erro);
    }
}

// Executa ao carregar
window.onload = carregarItens;