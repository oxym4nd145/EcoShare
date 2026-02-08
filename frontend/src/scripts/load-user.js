async function carregarPerfil() {
    const USUARIO_ID = 1; 

    try {
        const resposta = await fetch(`http://localhost:3000/api/usuario/completo/${USUARIO_ID}`);
        const user = await resposta.json();

        document.getElementById('user-nome').innerText = user.nome_usuario;
        document.getElementById('user-email').innerText = user.email;
        
        // Exibe a Mensalidade no Badge de destaque
        const badgeMensalidade = document.getElementById('user-mensalidade-badge');
        badgeMensalidade.innerText = user.tipo_mensalidade;
        
        // Estilização dinâmica baseada no plano
        if(user.tipo_mensalidade.toLowerCase() === 'plus') {
            badgeMensalidade.style.backgroundColor = 'var(--accent-gold)';
            badgeMensalidade.style.color = 'var(--text-dark)';
        }

        // Dados financeiros e pessoais
        document.getElementById('user-saldo').innerText = 
            user.saldo.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

        const data = new Date(user.data_nascimento);
        document.getElementById('user-data-nasc').innerText = data.toLocaleDateString('pt-BR');

        // Dados secundários
        document.getElementById('user-tipo-pessoa').innerText = user.nome_tipo_pessoa;
        document.getElementById('user-cep').innerText = user.cep || 'Não informado';

        // Preenchendo os novos campos de endereço
        document.getElementById('user-logradouro').innerText = user.logradouro || '...';
        document.getElementById('user-numero').innerText = user.numero || 'S/N';
        document.getElementById('user-bairro').innerText = user.bairro || '...';
        document.getElementById('user-cidade').innerText = user.cidade || '...';
        document.getElementById('user-uf').innerText = user.estado || '..';

    } catch (error) {
        console.error("Erro ao carregar perfil:", error);
    }
}

window.onload = carregarPerfil;