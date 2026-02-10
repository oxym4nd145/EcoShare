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
    const transacaoId = urlParams.get('trans'); // Tipo: Aluguel, Venda...
    const estadoId = urlParams.get('est');      // Condição: Novo, Usado...
    const ufParam = urlParams.get('uf');        // UF do endereço do usuário
    const buscaTermo = urlParams.get('busca');
    const dispParam = urlParams.get('disp');    // Status: Disponível, Em uso...

    try {
        const urlApi = new URL('http://localhost:3000/api/itens');
        
        // 1. Mapeamento correto para os parâmetros que o server.js espera
        if (categoriaId) urlApi.searchParams.append('cat', categoriaId);
        if (estadoId) urlApi.searchParams.append('est', estadoId);
        if (ufParam) urlApi.searchParams.append('uf', ufParam);
        if (buscaTermo) urlApi.searchParams.append('busca', buscaTermo);

        // 2. IMPORTANTE: No seu server.js, o filtro de Status (id_status) 
        // costuma ser recebido como 'disp'.
        if (dispParam && dispParam !== 'all') {
            urlApi.searchParams.append('disp', dispParam);
        } else if (!dispParam && !buscaTermo) {
            // Se quiser manter o padrão de mostrar apenas disponíveis na home:
            urlApi.searchParams.append('disp', '1'); 
        }

        // 3. NOVO: Adicionar o filtro de transação (Venda/Aluguel)
        // Certifique-se que seu server.js tenha: if (req.query.trans) ...
        if (transacaoId) urlApi.searchParams.append('trans', transacaoId);

        const resposta = await fetch(urlApi);
        const itens = await resposta.json();

        container.innerHTML = ''; 

        if (itens.length === 0) {
            container.innerHTML = `<p>Nenhum item encontrado.</p>`;
            return;
        }

        itens.forEach(item => {
            // O mapeamento aqui deve bater com o SELECT do server.js
            // item._id, item.nome, item.tipo (status), item.condicao (estado)
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
        console.error("Erro:", erro);
    }
}

window.onload = carregarItens;