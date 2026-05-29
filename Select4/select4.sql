SELECT
    e.nome AS escola,
    ROUND(
        SUM(s.total_acertos)::NUMERIC
        / NULLIF(SUM(s.total_questoes), 0) * 100
    , 2) AS percentual_acerto
FROM public.escolas             e
    JOIN public.matriculas m
        ON m.escola_id = e.id
    JOIN public.sessoes_simulado s
        ON s.aluno_id = m.aluno_id
WHERE s.status = 'concluida'
GROUP BY 
    e.id, e.nome
ORDER BY 
    percentual_acerto DESC;