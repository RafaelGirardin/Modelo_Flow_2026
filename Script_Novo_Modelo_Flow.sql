SELECT * 
FROM (SELECT  aloc.CD_ALOCACAO,
                                     aloc.DATA_SAIDA,
                                     aloc.DATA_CHEGADA,
                                     aloc.CD_TIPOCARGA,
                                     (DECODE((SELECT hvf.EXCESSO_CAMINHAO FROM Historico_Vazao_Frentes hvf WHERE hvf.CD_FAZENDA_LIBERADA = aloc.CD_FAZENDA_LIBERADA AND hvf.DATA_HORA BETWEEN (aloc.DATA_SAIDA - INTERVAL '5' MINUTE) AND aloc.DATA_SAIDA ORDER BY aloc.DATA_SAIDA DESC FETCH FIRST 1 ROW ONLY),'S',1,0)) EXCESSO_CAMINHAO,
                                     (SELECT asf.QTDE_COLHEDORA_OP FROM Alocacao_Situacao_Frentes asf WHERE asf.SEQ_ALOCACAO  = aloc.CD_ALOCACAO AND asf.CD_FAZENDA_LIBERADA = aloc.CD_FAZENDA_LIBERADA) COLHEDORAS_OP,
                                    (SELECT asf.QTDE_COLHEDORA_PA FROM Alocacao_Situacao_Frentes asf WHERE asf.SEQ_ALOCACAO  = aloc.CD_ALOCACAO AND asf.CD_FAZENDA_LIBERADA = aloc.CD_FAZENDA_LIBERADA) COLHEDORAS_PA,
                                    (SELECT asf.QTDE_TRATOR_OP FROM Alocacao_Situacao_Frentes asf WHERE asf.SEQ_ALOCACAO  = aloc.CD_ALOCACAO AND asf.CD_FAZENDA_LIBERADA = aloc.CD_FAZENDA_LIBERADA) TRANSBORDOS_OP,
                                    (SELECT asf.QTDE_TRATOR_PA FROM Alocacao_Situacao_Frentes asf WHERE asf.SEQ_ALOCACAO  = aloc.CD_ALOCACAO AND asf.CD_FAZENDA_LIBERADA = aloc.CD_FAZENDA_LIBERADA) TRANSBORDOS_PA,
                                    (SELECT asf.QTDE_CM_INDO  FROM Alocacao_Situacao_Frentes asf WHERE asf.SEQ_ALOCACAO  = aloc.CD_ALOCACAO AND asf.CD_FAZENDA_LIBERADA = aloc.CD_FAZENDA_LIBERADA) QTD_CAMINHAO_INDO,
                                    CASE WHEN (EXTRACT(HOUR FROM CAST(aloc.DATA_SAIDA AS TIMESTAMP)) >= 19 OR EXTRACT(HOUR FROM CAST(aloc.DATA_SAIDA AS TIMESTAMP)) <= 6) THEN
                                      1
                                    ELSE
                                      0
                                    END TURNO,
                                    Base_Dois.*,
                                    ((aloc.DATA_CHEGADA - aloc.DATA_SAIDA) * 24) HORAS_VIAGEM
            FROM (SELECT Base.*, 
                                                flib.CD_FAZENDA_LIBERADA
                            FROM   (SELECT fl.CD_FAZENDA,
                                                                  MEDIAN(((a.DATA_CHEGADA  - a.DATA_SAIDA)*24)/fl.DISTANCIA) DIFICULDADE_CHEGADA
                                               FROM Alocacao a,
                                                              Fazenda_Liberada fl
                                               WHERE a.CD_FAZENDA_LIBERADA  = fl.CD_FAZENDA_LIBERADA 
                                               AND        a.CD_SAFRA = 11341
                                               AND        a.INICIO_PARADA IS NULL
                                               AND        a.PARADA_FORCADA = 'N'
                                               AND        a.JUSTIFICATIVA_TERMINO_MANUAL IS NULL
                                               AND        a.TRANSFERIDO_FRENTEFAZENDA <> 'S'
                                               AND        ((a.data_chegada - a.data_saida) * 24) >= 0.4
                                               AND        ((a.data_chegada - a.data_saida) * 24) < 8
                                               GROUP BY fl.CD_FAZENDA) Base,
                                                                                                             Fazenda_Liberada flib
                            WHERE flib.CD_FAZENDA = Base.CD_FAZENDA) Base_Dois,
                                                                                                                                       Alocacao aloc
            WHERE aloc.CD_FAZENDA_LIBERADA = Base_Dois.CD_FAZENDA_LIBERADA
            AND        aloc.CD_SAFRA = 11341
            AND        aloc.data_chegada IS NOT NULL)
WHERE  COLHEDORAS_OP IS NOT NULL
AND        COLHEDORAS_PA IS NOT NULL
AND        TRANSBORDOS_OP IS NOT NULL
AND        TRANSBORDOS_PA IS NOT NULL
AND        QTD_CAMINHAO_INDO IS NOT NULL
AND        HORAS_VIAGEM >= 0.4
AND        HORAS_VIAGEM < 8
AND        COLHEDORAS_OP >= 1
AND        TRANSBORDOS_OP >= 1

