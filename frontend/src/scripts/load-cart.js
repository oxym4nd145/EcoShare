/**
 * Transforma strings em classes seguras para CSS (ex: "Doação" -> "doacao")
 */
function formatarClasse(texto) {
    if (!texto) return 'default';
    return texto
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, "")
        .replace(/\s+/g, '-')
        .trim();
}

/**
 * Renderiza a lista de itens e o total estimado
 */
function renderizarCarrinho() {
    const lista = document.getElementById('cart-list');
    const totalTxt = document.getElementById('total-valor');
    const containerAcoes = document.querySelector('.summary-total')?.parentElement;

    // Recupera os dados do localStorage
    const carrinho = JSON.parse(localStorage.getItem('ecoshare_cart')) || [];

    // Estado: Carrinho Vazio
    if (carrinho.length === 0) {
        lista.innerHTML = `
            <div style="text-align: center; padding: 40px 20px;">
                <img src="./src/imgs/cart-green.svg" style="width: 50px; opacity: 0.5; margin-bottom: 15px;">
                <p style="color: #666; font-weight: 600;">Seu carrinho está vazio.</p>
                <a href="index.html" style="display: inline-block; margin-top: 20px; color: var(--primary-green); font-weight: bold; text-decoration: none;">
                    ← Voltar para a busca
                </a>
            </div>`;
        
        if (containerAcoes) containerAcoes.style.display = 'none';
        return;
    }

    // Estado: Com Itens
    if (containerAcoes) containerAcoes.style.display = 'block';
    lista.innerHTML = ""; 
    let totalGeral = 0;

    carrinho.forEach((item, index) => {
        // Lógica de Preço: Aluguel tem taxa fixa, outros são gratuitos
        const preco = item.tipo === 'Aluguel' ? 15.00 : 0.00;
        totalGeral += preco;
        const classeTipo = formatarClasse(item.tipo);

        lista.innerHTML += `
            <article class="cart-item" style="display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #eee; padding: 1.5rem 0;">
                <div style="display: flex; align-items: center; gap: 20px;">
                    <img src="${item.foto || './src/imgs/recycle-sign.svg'}" alt="${item.nome}" style="width: 100px; height: 75px; object-fit: cover; border-radius: 8px; box-shadow: var(--shadow-sm);">
                    <div>
                        <span class="badge type-${classeTipo}" style="font-size: 0.65rem; padding: 2px 8px; border-radius: 20px;">${item.tipo}</span>
                        <h3 style="margin: 5px 0; font-size: 1.1rem; color: var(--text-dark);">${item.nome}</h3>
                        <p style="font-size: 0.9rem; color: var(--primary-green); font-weight: 600;">
                            ${preco === 0 ? 'Grátis' : 'Taxa: R$ ' + preco.toFixed(2)}
                        </p>
                    </div>
                </div>
                <button onclick="removerDoCarrinho(${index})" class="btn-remove" style="background: none; border: none; cursor: pointer; padding: 10px;" title="Remover item">
                    <img src="./src/imgs/trash.svg" alt="Remover" style="width: 20px; opacity: 0.5; transition: 0.3s;" onmouseover="this.style.opacity=1" onmouseout="this.style.opacity=0.5">
                </button>
            </article>
        `;
    });

    totalTxt.innerText = `R$ ${totalGeral.toFixed(2)}`;
}

/**
 * Remove um item específico pelo índice do array
 */
function removerDoCarrinho(index) {
    let carrinho = JSON.parse(localStorage.getItem('ecoshare_cart')) || [];
    carrinho.splice(index, 1);
    localStorage.setItem('ecoshare_cart', JSON.stringify(carrinho));
    renderizarCarrinho();
}

/**
 * Inicialização
 */
document.addEventListener('DOMContentLoaded', () => {
    renderizarCarrinho();

    const btnCheckout = document.querySelector('.btn-checkout');
    if (btnCheckout) {
        btnCheckout.onclick = () => {
            alert("Solicitação enviada com sucesso! Verifique suas mensagens para combinar a entrega.");
            localStorage.removeItem('ecoshare_cart');
            window.location.href = 'index.html';
        };
    }
});