function formatarClasse(texto) {
    if (!texto) return 'default';
    return texto
        .toLowerCase()               // 1. Tudo minúsculo
        .normalize('NFD')            // 2. Separa os acentos das letras
        .replace(/[\u0300-\u036f]/g, "") // 3. Remove os acentos
        .replace(/\s+/g, '-')        // 4. Troca ESPAÇOS por TRAÇOS
        .trim();                     // 5. Remove espaços extras nas pontas
}

async function carregarItens() {
    const container = document.getElementById('items-container');
    
    // 1. CAPTURA TODOS OS PARÂMETROS DA URL
    const urlParams = new URLSearchParams(window.location.search);
    const categoriaId = urlParams.get('cat');
    const transacaoId = urlParams.get('trans');
    let disponibilidadeId = urlParams.get('disp');

    if (disponibilidadeId === null) {
        disponibilidadeId = '1';
    }

    const estadoId = urlParams.get('est');
    const buscaTermo = urlParams.get('busca'); // <--- NOVO: Captura o termo de busca

    try {
        const urlApi = new URL('http://localhost:3000/api/itens');
        
        // Adiciona os parâmetros se existirem
        if (categoriaId) urlApi.searchParams.append('cat', categoriaId);
        if (transacaoId) urlApi.searchParams.append('trans', transacaoId);

        if (disponibilidadeId && disponibilidadeId !== '') {
            urlApi.searchParams.append('disp', disponibilidadeId);
        }

        if (estadoId) urlApi.searchParams.append('est', estadoId);
        
        // <--- NOVO: Envia a busca para a API
        if (buscaTermo) {
            urlApi.searchParams.append('busca', buscaTermo);
        }

        const resposta = await fetch(urlApi);
        if (!resposta.ok) throw new Error(`Erro na API: ${resposta.status}`);

        const itens = await resposta.json();

        container.innerHTML = ''; 

        // Verifica se a lista está vazia
        if (itens.length === 0) {
            // Se tiver uma busca, mostramos qual termo não foi encontrado
            const msgErro = buscaTermo 
                ? `Nenhum item encontrado para "<strong>${buscaTermo}</strong>".`
                : 'Nenhum item encontrado com esses filtros.';

            container.innerHTML = `
                <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #666;">
                    <img src="./src/imgs/search.svg" style="width: 40px; opacity: 0.5; margin-bottom: 10px;">
                    <p>${msgErro}</p>
                    <a href="index.html" style="color: #2E7D32; text-decoration: underline;">Limpar filtros</a>
                </div>
            `;
            return;
        }

        // Renderiza os cards (código existente...)
        itens.forEach(item => {
            
            const card = document.createElement('a');
            card.href = `item.html?id=${item._id}`;
            card.className = 'product-card';

            const temFoto = item.foto && item.foto.trim() !== '';
            const imagemSrc = temFoto ? item.foto : './src/imgs/recycle-sign.svg';
            const imgStyle = temFoto 
                ? 'width: 100%; height: 100%; object-fit: cover;' 
                : 'width: 60%; height: 60%; object-fit: contain; opacity: 0.6;';

            const classeTipo = formatarClasse(item.tipo);

            card.innerHTML = `
                <div class="img-container" style="width: 100%; height: 200px; display: flex; align-items: center; justify-content: center; background-color: #f9f9f9; border-radius: 8px 8px 0 0; overflow: hidden;">
                    <img src="${imagemSrc}" alt="${item.nome}" style="${imgStyle}">
                </div>
                <div class="card-info">
                    <span class="badge type-${classeTipo}">
                        ${item.tipo || 'Disponível'}
                    </span>
                    <h3>${item.nome}</h3>
                    <p class="item-status">
                        <span style="color: #666; font-size: 0.9em;">Condição:</span> 
                        <strong>${item.condicao || 'Não informada'}</strong>
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