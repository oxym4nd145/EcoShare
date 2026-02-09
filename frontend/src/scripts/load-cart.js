function renderizarCarrinho() {
    const lista = document.getElementById('cart-list');
    const totalTxt = document.getElementById('total-valor');
    const btnCheckout = document.querySelector('.btn-checkout');
    
    // Selecionamos a div que envolve o resumo e os botões
    const containerAcoes = document.querySelector('.cart-actions').parentElement;

    const carrinho = JSON.parse(localStorage.getItem('ecoshare_cart')) || [];

    // 1. Se o carrinho estiver vazio
    if (carrinho.length === 0) {
        lista.innerHTML = `
            <div style="text-align: center; padding: 20px;" class="back-cart-gp">
                <p>Seu carrinho está vazio.</p>
                <br>
                <a href="index.html" class="btn-back back-cart" style="color: #2e7d32; text-decoration: none; font-weight: bold;">
                    <img src="/src/imgs/arrow-left.svg" class="icon back-icon" style="width: 15px; margin-right: 5px;">
                    <span>Voltar para loja</span>
                </a>
            </div>`;
        
        // Esconde toda a parte de total e botões
        if (containerAcoes) containerAcoes.style.display = 'none';
        return;
    }

    // 2. Se houver itens, garante que os botões apareçam
    if (containerAcoes) containerAcoes.style.display = 'block';

    lista.innerHTML = ""; 
    let totalGeral = 0;

    carrinho.forEach((item, index) => {
        const preco = item.tipo === 'Aluguel' ? 15.00 : 0.00;
        totalGeral += preco;

        lista.innerHTML += `
            <article class="cart-item" style="display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #eee; padding: 10px 0;">
                <div style="display: flex; align-items: center; gap: 15px;">
                    <img src="${item.imagem || 'src/imgs/recycle-sign.svg'}" alt="${item.nome}" style="width: 80px; height: 60px; object-fit: cover; border-radius: 4px;">
                    <div>
                        <span class="badge" style="font-size: 0.7rem; background: #eee; padding: 2px 5px; border-radius: 3px;">${item.tipo}</span>
                        <h3 style="margin: 5px 0; font-size: 1rem;">${item.nome}</h3>
                        <p style="font-size: 0.9rem; color: #666;">${preco === 0 ? 'Grátis' : 'R$ ' + preco.toFixed(2)}</p>
                    </div>
                </div>
                <button onclick="removerDoCarrinho(${index})" style="background: none; border: none; cursor: pointer;" title="Remover item">
                    <img src="./src/imgs/trash.svg" alt="Remover" style="width: 20px;">
                </button>
            </article>
        `;
    });

    totalTxt.innerText = `R$ ${totalGeral.toFixed(2)}`;
}

// Inicializa a função quando a página carregar
window.onload = renderizarCarrinho;