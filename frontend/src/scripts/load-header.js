async function carregarCategoriasHeader() {
    const navGroup = document.getElementById('categorias-nav');
    if (!navGroup) return; 

    // 1. Obtém o ID da categoria que está na URL atual
    const urlParams = new URLSearchParams(window.location.search);
    const categoriaAtiva = urlParams.get('cat');

    try {
        const resposta = await fetch('http://localhost:3000/api/categorias');
        const categorias = await resposta.json();

        navGroup.innerHTML = '<span class="sub-nav-label">Categorias:</span>';

        categorias.forEach(cat => {
            const link = document.createElement('a');
            link.href = `index.html?cat=${cat.id_categoria}`;
            link.textContent = cat.tipo_categoria;

            // 2. Compara o ID do link com o ID da URL
            // Usamos == (dois iguais) porque um pode ser string e outro número
            if (categoriaAtiva == cat.id_categoria) {
                link.style.fontWeight = 'bold';
                link.style.textDecoration = 'underline'; // Opcional: ajuda a destacar mais
                link.style.color = 'var(--white)'; // Garante que fique visível
            }

            navGroup.appendChild(link);
        });

        // Adiciona o botão de Limpar
        const btnLimpar = document.createElement('button');
        btnLimpar.textContent = 'Limpar Filtros';
        btnLimpar.className = 'btn-limpar';
        btnLimpar.onclick = () => window.location.href = 'index.html';
        navGroup.appendChild(btnLimpar);

    } catch (erro) {
        console.error("Erro ao carregar categorias:", erro);
    }
}

document.addEventListener('DOMContentLoaded', carregarCategoriasHeader);