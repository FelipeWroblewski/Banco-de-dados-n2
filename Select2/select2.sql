SELECT
    p.id,
    p.nome_completo
FROM public.profiles p
WHERE p.papel = 'aluno'
    AND NOT EXISTS (
        SELECT 1
        FROM public.sessoes_simulado s
        WHERE s.aluno_id = p.id
    )
ORDER BY p.nome_completo;