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
    
    // 1. Coleta os parâmetros da URL
    const categoriaId = urlParams.get('cat');
    const transacaoId = urlParams.get('trans');
    const estadoId = urlParams.get('est');
    const buscaTermo = urlParams.get('busca');
    const dispParam = urlParams.get('disp');

    // 2. Lógica da Disponibilidade (Regra do "all" e padrão "1")
    let disponibilidadeId = "";

    if (dispParam === "all") {
        disponibilidadeId = ""; // Não filtra nada
    } else if (dispParam !== null) {
        disponibilidadeId = dispParam; // Filtra pelo ID da URL (1, 2, 3...)
    } else if (!buscaTermo) {
        // Se for o primeiro acesso (sem params e sem busca), padrão é 1
        disponibilidadeId = "1";
    }

    try {
        const urlApi = new URL('http://localhost:3000/api/itens');
        
        // 3. Adiciona os parâmetros à chamada da API (sem repetições)
        if (categoriaId) urlApi.searchParams.append('cat', categoriaId);
        if (transacaoId) urlApi.searchParams.append('trans', transacaoId);
        if (estadoId) urlApi.searchParams.append('est', estadoId);
        if (buscaTermo) urlApi.searchParams.append('busca', buscaTermo);
        
        // Só anexa disponibilidade se não for "Todos" (vazio)
        if (disponibilidadeId) {
            urlApi.searchParams.append('disp', disponibilidadeId);
        }

        const resposta = await fetch(urlApi);
        if (!resposta.ok) throw new Error(`Erro na API: ${resposta.status}`);

        const itens = await resposta.json();

        // 4. Renderização na tela
        container.innerHTML = ''; 

        if (itens.length === 0) {
            const msgErro = buscaTermo 
                ? `Nenhum item encontrado para "<strong>${buscaTermo}</strong>".`
                : 'Nenhum item encontrado com esses filtros.';

            container.innerHTML = `
                <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #666;">
                    <img src="./src/imgs/search.svg" style="width: 40px; opacity: 0.5; margin-bottom: 10px;">
                    <p>${msgErro}</p>
                    <a href="index.html" style="color: #2E7D32; text-decoration: underline;">Limpar todos os filtros</a>
                </div>
            `;
            return;
        }

        itens.forEach(item => {
            const card = document.createElement('a');
            card.href = `item.html?id=${item._id}`;
            card.className = 'product-card';

            const imagemSrc = item.foto || './src/imgs/recycle-sign.svg';
            const classeTipo = formatarClasse(item.tipo);

            card.innerHTML = `
                <div class="img-container" style="width: 100%; height: 200px; display: flex; align-items: center; justify-content: center; background-color: #f9f9f9; border-radius: 8px 8px 0 0; overflow: hidden;">
                    <img src="${imagemSrc}" alt="${item.nome}" style="width: 100%; height: 100%; object-fit: cover;">
                </div>
                <div class="card-info">
                    <span class="badge type-${classeTipo}">${item.tipo || 'Disponível'}</span>
                    <h3>${item.nome}</h3>
                    <p class="item-status">
                        <span style="color: #666; font-size: 0.9em;">Condição:</span> 
                        <strong>${item.condicao || item.estado || 'Não informada'}</strong>
                    </p>
                </div>
            `;
            container.appendChild(card);
        });

    } catch (erro) {
        console.error("Erro ao carregar itens:", erro);
        container.innerHTML = '<p style="text-align:center; color: red;">Erro ao conectar com o servidor.</p>';
    }
}

window.onload = carregarItens;