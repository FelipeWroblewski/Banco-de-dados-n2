SELECT
    p.nome_completo AS aluno,
    SUM(s.total_acertos) AS total_acertos_acumulados,
    SUM(s.total_questoes) AS total_questoes_respondidas
FROM public.profiles p
    JOIN public.sessoes_simulado s
        ON s.aluno_id = p.id
WHERE s.status = 'concluida'
    AND p.papel = 'aluno'
GROUP BY 
    p.id,
    p.nome_completo
HAVING 
    SUM(s.total_questoes) >= 100
ORDER BY 
    total_acertos_acumulados DESC
LIMIT 5;