function formatarClasse(texto) {
    if (!texto) return 'default';
    return texto
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, "") 
        .replace(/\s+/g, '-')
        .trim();
}

async function carregarItens() {
    const container = document.getElementById('items-container');
    if (!container) return;

    const urlParams = new URLSearchParams(window.location.search);
    
    const categoriaId = urlParams.get('cat');
    const estadoId = urlParams.get('est');
    const dispId = urlParams.get('disp');
    const buscaTermo = urlParams.get('busca');

    try {
        const urlApi = new URL('http://localhost:3000/api/itens');
        
        if (categoriaId) urlApi.searchParams.append('cat', categoriaId);
        if (estadoId) urlApi.searchParams.append('est', estadoId);
        if (dispId) urlApi.searchParams.append('disp', dispId);
        if (buscaTermo) urlApi.searchParams.append('busca', buscaTermo);

        console.log('Buscando itens com URL:', urlApi.toString());

        const resposta = await fetch(urlApi);
        const itens = await resposta.json();

        container.innerHTML = '';

        if (itens.length === 0) {
            container.innerHTML = `<p>Nenhum item encontrado.</p>`;
            return;
        }

        itens.forEach(item => {
            const card = document.createElement('a');
            card.href = `item.html?id=${item._id}`;
            card.className = 'product-card';
            
            const imagemSrc = item.foto || './src/imgs/recycle-sign.svg';
            const classeTipo = formatarClasse(item.tipo);

            card.innerHTML = `
                <div class="img-container">
                    <img src="${imagemSrc}" alt="${item.nome}">
                </div>
                <div class="card-info">
                    <span class="badge type-${classeTipo}">${item.tipo}</span>
                    <h3>${item.nome}</h3>
                    <p class="item-status">
                        <span>Condição:</span> <strong>${item.condicao}</strong>
                    </p>
                </div>
            `;
            container.appendChild(card);
        });

    } catch (erro) {
        console.error("Erro ao carregar itens:", erro);
    }
}

window.onload = carregarItens;