CREATE OR REPLACE VIEW sigh.v_controle_acesso
AS
SELECT 		pac.id_paciente	id_paciente,
			SUBSTRING(nm_paciente,1,255)paciente,
			pac.spp prontuario,
			TO_CHAR(fai.data_atendimento,'DD/MM/YYYY')data_entrada, 
			TRUNC(CURRENT_DATE - fai.data_atENDimento) dias_internacao,
			que.nm_quarto ||' - '||lei.nm_leito leito,
			(SELECT DISTINCT sp.nm_setor_posto 
			FROM sigh.troca_situacao_leito tsl 
			INNER JOIN sigh.leitos l ON l.id_leito = tsl.cod_leito 
			INNER JOIN sigh.ficha_amb_int fic  ON fic.id_fia  = tsl.cod_fia
			INNER JOIN sigh.quartos_enfermarias qe ON qe.id_quarto_enf = l.cod_quarto_enf 
			INNER JOIN sigh.setores_postos sp ON sp.id_setor_posto = qe.cod_setor_posto 
			INNER JOIN sigh.unidades u ON u.id_unidade = sp.cod_unidade 
			WHERE fic.cod_paciente = fai.cod_paciente
			and 	fic.data_alta is null
			AND 	tsl.id_troca_sit_leito =  (SELECT MIN(a.id_troca_sit_leito)
								 FROM sigh.troca_situacao_leito a 
								 INNER JOIN sigh.leitos b ON b.id_leito = a.cod_leito 
								 INNER JOIN sigh.ficha_amb_int c  ON c.id_fia  = a.cod_fia
								 INNER JOIN sigh.quartos_enfermarias d ON d.id_quarto_enf = b.cod_quarto_enf 
								 INNER JOIN sigh.setores_postos e ON e.id_setor_posto = d.cod_setor_posto 
								 INNER JOIN sigh.unidades f ON f.id_unidade = e.cod_unidade 
								 WHERE c.cod_paciente = fic.cod_paciente
								 and 	c.data_alta is null)) 							
			setor, --setor de entrada (primeiro setor)
			spo.nm_setor_posto setor_atual,
			TO_CHAR(pac.data_nasc,'DD/MM/YYYY') data_nasc,
			EXTRACT(YEAR FROM age(pac.data_nasc)) idade,
			CASE WHEN lei.permite_acomp = 'T' THEN 'SIM'
				 WHEN lei.permite_acomp = 'F' THEN 'NÃO'
				 ELSE NULL
			END permite_visita,	
			sex.nm_sexo sexo,
			SUBSTRING(pre.nm_prestador,1,255) medico,
			CASE 	WHEN fai.em_isolamento = 'T' 
						THEN 'SIM'
					WHEN fai.em_isolamento = 'F'
						THEN 'NÃO'
					ELSE NULL
			END isolado,
			SUBSTRING(mun.nm_municipio,1,255) cidade,
			que.numero_max_visitante  qtd_visitas,
			que.numero_max_acompanhante qtd_acompanhantes 
FROM 		sigh.pacientes pac
INNER JOIN 	sigh.ficha_amb_int fai ON fai.cod_paciente 	= pac.id_paciente
INNER JOIN	sigh.prestadores pre ON pre.id_prestador 	= fai.cod_medico
INNER JOIN 	endereco_sigh.municipios mun ON mun.id_municipio 	= pac.cod_municipio
INNER JOIN 	sigh.leitos lei ON lei.id_leito 		= fai.cod_leito
INNER JOIN  sigh.quartos_enfermarias que ON que.id_quarto_enf	= lei.cod_quarto_enf 
INNER JOIN  sigh.setores_postos spo ON spo.id_setor_posto   = que.cod_setor_posto
INNER JOIN  sigh.unidades uni ON uni.id_unidade 		= spo.cod_unidade 
INNER JOIN 	sigh.sexos sex ON sex.id_sexo 			= pac.cod_sexo
WHERE 		fai.data_alta IS NULL
AND         pac.data_obito  IS null;
