function renderizarCarrinho() {
    const lista = document.getElementById('cart-list');
    const totalTxt = document.getElementById('total-valor');
    
    // 1. Busca os itens salvos no LocalStorage (memória do navegador)
    const carrinho = JSON.parse(localStorage.getItem('ecoshare_cart')) || [];

    // 2. Verifica se o carrinho está vazio
    if (carrinho.length === 0) {
        lista.innerHTML = `
            <div style="text-align: center; padding: 20px;">
                <p>Seu carrinho está vazio.</p>
                <br>
                <a href="index.html" style="color: #2e7d32; text-decoration: none; font-weight: bold;">← Voltar para a loja</a>
            </div>`;
        totalTxt.innerText = "R$ 0,00";
        return;
    }

    // 3. Limpa o container e renderiza os itens
    lista.innerHTML = ""; 
    let totalGeral = 0;

    carrinho.forEach((item, index) => {
        // Lógica de preço: Aluguel assume um valor base, Doação/Empréstimo é zero
        const preco = item.tipo === 'Aluguel' ? 15.00 : 0.00;
        totalGeral += preco;

        // Cria o HTML do card do item no carrinho
        const itemHTML = `
            <article class="cart-item" style="display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #eee; padding: 10px 0;">
                <div style="display: flex; align-items: center; gap: 15px;">
                    <img src="${item.imagem || 'https://via.placeholder.com/80'}" alt="${item.nome}" style="width: 80px; height: 60px; object-fit: cover; border-radius: 4px;">
                    <div>
                        <span class="badge" style="font-size: 0.7rem;">${item.tipo}</span>
                        <h3 style="margin: 5px 0;">${item.nome}</h3>
                        <p style="font-size: 0.9rem; color: #666;">${preco === 0 ? 'Grátis' : 'R$ ' + preco.toFixed(2)}</p>
                    </div>
                </div>
                <button onclick="removerDoCarrinho(${index})" style="background: none; border: none; cursor: pointer; color: #ff4444; font-size: 1.2rem;" title="Remover item">
                    <img src="./src/imgs/trash.svg" alt="Trash can" class="icon remove-icon">
                </button>
            </article>
        `;
        lista.innerHTML += itemHTML;
    });

    // 4. Atualiza o valor total na tela
    totalTxt.innerText = `R$ ${totalGeral.toFixed(2)}`;
}

// Função para remover um item específico
function removerDoCarrinho(index) {
    let carrinho = JSON.parse(localStorage.getItem('ecoshare_cart')) || [];
    
    // Remove o item do array pelo índice
    carrinho.splice(index, 1);
    
    // Salva a nova lista no LocalStorage
    localStorage.setItem('ecoshare_cart', JSON.stringify(carrinho));
    
    // Atualiza a tela
    renderizarCarrinho();
}

// Inicializa a função quando a página carregar
window.onload = renderizarCarrinho;