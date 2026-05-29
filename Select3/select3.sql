SELECT
    p.nome_completo AS aluno,
    r.alternativa_escolhida,
    r.acertou
FROM public.respostas r
    JOIN public.sessoes_simulado s  
        ON s.id = r.sessao_id
    JOIN public.profiles p
        ON p.id = s.aluno_id
    JOIN public.questoes q
        ON q.id = r.questao_id
    JOIN public.matriculas m
        ON m.aluno_id = p.id
    JOIN public.escolas e
        ON e.id = m.escola_id
WHERE q.numero_interno = 8 --OBS: numero interno = 8, pois não criamos 45 questões. Fizemos poucas linhas de população, porém o id é 45.
    AND e.cnpj = '12345678000199' 
ORDER BY 
p.nome_completo; 