Select base5.CustomerCode
,base5.account_group
,base5.PayType
,sum(base5.amount) as amount
,sum(base5.pdd_amount) as pdd_amount
,sum(base5.pdd_amount_extra) as pdd_amount_extra
,sum(base5.total_pdd_amount) as total_pdd_amount
,sum(base5.pdd_pt2_amount) as  pdd_pt2_amount


from 
(Select base4.Id
,base4.Stt
,base4.TransCode
,base4.DocCode
,base4.DocDate
,base4.DocNo
,base4.DocDateAcc
,base4.DocNoAcc
,base4.Description
,base4.PayType
,base4.IsPrepayment
,base4.Account
,base4.CustomerCode
,base4.DueDate
,base4.CurrencyCode
,base4.ExchangeRate
,base4.Year
,base4.AtchDocDate
,base4.AtchDocNo
,base4.IsActive
,base4.CreatedAt
,base4.account_group
,base4.ad_is_active
,base4.Posted
,base4.DocStatus
,base4.doc_year

,case when base4.account_group = '331' and base4.PayType = 1 then isnull(base4.Amount,0)
		  when base4.account_group = '331' and base4.PayType = 2 then (-1)*isnull(base4.Amount,0)
		  when base4.account_group = '131' and base4.PayType = 1 then (-1)*isnull(base4.Amount,0)
		  when base4.account_group = '131' and base4.PayType = 2 then isnull(base4.Amount,0)
		  else isnull(base4.Amount,0) end as amount

,case when base4.account_group = '331' and base4.PayType = 1 then isnull(base4.pdd_amount,0)
		  when base4.account_group = '331' and base4.PayType = 2 then (-1)*isnull(base4.pdd_amount,0)
		  when base4.account_group = '131' and base4.PayType = 1 then (-1)*isnull(base4.pdd_amount,0)
		  when base4.account_group = '131' and base4.PayType = 2 then isnull(base4.pdd_amount,0)
		  else isnull(base4.pdd_amount,0) end as pdd_amount

,isnull(base4.pdd_amount_extra,0) as pdd_amount_extra

,case when base4.account_group = '331' and base4.PayType = 1 then isnull(base4.pdd_amount,0)
		  when base4.account_group = '331' and base4.PayType = 2 then (-1)*isnull(base4.pdd_amount,0)
		  when base4.account_group = '131' and base4.PayType = 1 then (-1)*isnull(base4.pdd_amount,0)
		  when base4.account_group = '131' and base4.PayType = 2 then isnull(base4.pdd_amount,0)
		  else isnull(base4.pdd_amount,0) end + isnull(base4.pdd_amount_extra,0) as total_pdd_amount

,case when base4.account_group = '331' and base4.PayType = 1 then isnull(base4.pdd_pt2_amount,0)
		  when base4.account_group = '331' and base4.PayType = 2 then (-1)*isnull(base4.pdd_pt2_amount,0)
		  when base4.account_group = '131' and base4.PayType = 1 then (-1)*isnull(base4.pdd_pt2_amount,0)
		  when base4.account_group = '131' and base4.PayType = 2 then isnull(base4.pdd_pt2_amount,0)
		  else isnull(base4.pdd_pt2_amount,0) end as pdd_pt2_amount

from
(Select base3.*
,sum(pdd_pt2.Amount) as pdd_pt2_amount

from
(Select base2.Id
,base2.Stt
,base2.TransCode
,base2.DocCode
,base2.DocDate
,base2.DocNo
,base2.DocDateAcc
,base2.DocNoAcc
,base2.Description
,base2.PayType
,base2.IsPrepayment
,base2.Account
,base2.CustomerCode
,base2.DueDate
,base2.CurrencyCode
,base2.ExchangeRate
,base2.Amount
,base2.Year
,base2.AtchDocDate
,base2.AtchDocNo
,base2.IsActive
,base2.CreatedAt
,base2.account_group
,base2.ad_is_active
,base2.Posted
,base2.DocStatus
,base2.doc_year
,base2.pdd_amount
,sum(case when base2.bdk_account_group = '331' and base2.PayType = 1 then base2.pdd_amount_extra
		  when base2.bdk_account_group = '331' and base2.PayType = 2 then (-1)*base2.pdd_amount_extra
		  when base2.bdk_account_group = '131' and base2.PayType = 1 then (-1)*base2.pdd_amount_extra
		  when base2.bdk_account_group = '131' and base2.PayType = 2 then base2.pdd_amount_extra
		  else base2.pdd_amount_extra end) as pdd_amount_extra

from
	(Select base1.*
	,bdk.account_group as bdk_account_group
	,sum(case -- when base1.Stt = 'B010000000225460' then 341999910 -- exceptional case: C24TCP692 co C24TCP1093 dieu chinh giam
			  when base1.Stt = 'B010000000096229' then 	33926407 -- exceptional case: 0005961 bi nham thanh 0005916 trong B0100000178513DK
			  when base1.Stt = 'B010000000096491' then 17999999 - 7852403 -- exceptional case: phieu goc da thanh toan 7852403, phieu DK B0100000178531DK lai thanh toan full
			  when base1.Stt = 'B010000000110507' then 60890952 -- exceptionao case: M0217, docno 2020323
			  when base1.Stt = 'B010000000114043' then 2651971 -- exceptionao case: M0217, docno 2020323
			  when base1.Stt = 'B010000000206316' then 22259160.00 -- exceptionao case: M0217, docno P-149
			  when base1.Stt = 'B010000000206317' then 54458250.00 -- exceptionao case: M0217, docno P-150
			  when base1.Stt = 'B010000000223973' then 80322.00 -- exceptionao case: D0167, docno P-439
			else bdk.pdd_amount_for_dk end) as pdd_amount_extra

	from
		(select base.Id
		,base.Stt
		,base.TransCode
		,base.DocCode
		,base.DocDate
		,base.DocNo
		,base.DocDateAcc
		,base.DocNoAcc
		,base.Description
		,base.PayType
		,base.IsPrepayment
		,base.Account
		,base.CustomerCode
		,base.DueDate
		,base.CurrencyCode
		,base.ExchangeRate
		,base.Amount
		,base.Year
		,base.AtchDocDate
		,base.AtchDocNo
		,base.IsActive
		,base.CreatedAt
		,base.account_group
		,base.ad_is_active
		,base.Posted
		,base.DocStatus
		,base.doc_year
		,sum(pdd_2.Amount) as pdd_amount




		from
			(Select pd.*
			,case when pd.Account like '131%' then '131'
				  when pd.Account like '331%' then '331'
				  else N'Others' end as account_group
			,ad.IsActive  as ad_is_active
			,ad.Posted
			,ad.DocStatus
			,year(pd.DocDate) as doc_year

			from B7R2_VCP_TH.dbo.B30PayDoc pd
				left join B7R2_VCP_TH.dbo.B30AccDoc ad on ad.Stt = pd.Stt and ad.CustomerCode = pd.CustomerCode
			--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Id = pdd.ParentId
			--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 on pd.Stt = pdd_2.Stt_Cd_Htt and pd.CustomerCode = pdd_2.CustomerCode

			where 1=1
			and isnull(ad.IsActive,1) = 1
			and (pd.IsOpenBalance = 0 OR (pd.IsOpenBalance = 1 and pd.Year = 2018) OR pd.Stt in ('B0100000408421DK')) -- exceptional
			and pd.IsActive = 1 -- mới thêm

		
			)base
				left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 on base.Stt = pdd_2.Stt_Cd_Htt and base.CustomerCode = pdd_2.CustomerCode and pdd_2.IsActive = 1 and (pdd_2.Account LIKE '131%' OR pdd_2.Account LIKE '331%') and base.Account = pdd_2.Account

		where 1=1
		and isnull(base.CustomerCode,'') <> ''
		and base.Stt not in ('B010000000177365')

		--and base.CustomerCode = 'B0023'
		--and base.DocNo = '0001242'

		GROUP BY base.Id,base.Stt,base.TransCode,base.DocCode,base.DocDate,base.DocNo,base.DocDateAcc,base.DocNoAcc,base.Description,base.PayType,base.IsPrepayment,base.Account,base.CustomerCode,base.DueDate,base.CurrencyCode,base.ExchangeRate,base.Amount,base.Year,base.AtchDocDate,base.AtchDocNo,base.IsActive,base.CreatedAt,base.account_group,base.ad_is_active,base.Posted,base.DocStatus,base.doc_year

		)base1
			left join (Select pd.Stt
						,pd.DocCode
						,case when pd.Stt = 'B0100000463962DK' then '2024-12-30' -- exceptional case chung tu C24TCP14457 co record DK bi lech 1 ngay (2024-12-31) so voi ngay dung (2024-12-31)
							else pd.DocDate end as DocDate
						,pd.DocNo
						,pd.Description
						,pd.Account
						,case when pd.Account like '131%' then '131'
							 when pd.Account like '331%' then '331'
							else N'Others' end as account_group
						,pd.PayType
						,pd.CustomerCode
						,pd.Amount
						,sum(pdd.Amount) as pdd_amount_for_dk
				
						from B7R2_VCP_TH.dbo.B30PayDoc pd 
							left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Stt = pdd.Stt_Cd_Htt and pd.CustomerCode = pdd.CustomerCode and pdd.IsActive = 1 and (pdd.Account LIKE '131%' OR pdd.Account LIKE '331%') and pd.Account = pdd.Account
								
						where 1=1
						and pd.IsActive = 1
						and pd.Stt  like '%DK%'
						and pd.Stt not in ('B0100000288691DK','B0100000402427DK','B0100000350074DK','B0100000178532DK','B0100000180049DK','B0100000351776DK','B0100000351413DK','B0100000180013DK','B0100000180021DK',
											'B0100000180018DK','B0100000180023DK','B0100000180027DK','B0100000180028DK','B0100000180031DK','B0100000180033DK','B0100000180034DK','B0100000180036DK','B0100000180040DK',
											'B0100000180042DK','B0100000180044DK','B0100000180047DK','B0100000256114DK','B0100000180453DK','B0100000180448DK','B0100000180451DK','B0100000180454DK','B0100000180458DK',
											'B0100000180601DK','B0100000180673DK','B0100000180009DK'
											) -- exceptional cases / clean data
					--	and year(pd.DocDate) >= 2018
					--	and ((year(pd.DocDate) >= 2018 and isnull(pd.DocNo,'') <> '') OR (year(pd.DocDate) < 2018 and isnull(pd.DocNo,'') = ''))

						GROUP BY pd.Stt
								,pd.DocCode
								,pd.DocDate
								,pd.DocNo
								,pd.Description
								,pd.Account
								,pd.PayType
								,pd.CustomerCode
								,pd.Amount
							
						)bdk on bdk.DocCode = base1.DocCode and bdk.DocNo = base1.DocNo and bdk.CustomerCode = base1.CustomerCode and bdk.Stt <> base1.Stt and base1.DocDate = bdk.DocDate

	GROUP BY base1.Id,base1.Stt,base1.TransCode,base1.DocCode,base1.DocDate,base1.DocNo,base1.DocDateAcc,base1.DocNoAcc,base1.Description,base1.PayType,base1.IsPrepayment,base1.Account,base1.CustomerCode,base1.DueDate,base1.CurrencyCode,base1.ExchangeRate,base1.Amount,base1.Year,base1.AtchDocDate,base1.AtchDocNo,base1.IsActive,base1.CreatedAt,base1.account_group,base1.ad_is_active,base1.Posted,base1.DocStatus,base1.doc_year,base1.pdd_amount,bdk.account_group

	)base2

	GROUP BY base2.Id,base2.Stt,base2.TransCode,base2.DocCode,base2.DocDate,base2.DocNo,base2.DocDateAcc,base2.DocNoAcc,base2.Description,base2.PayType,base2.IsPrepayment,base2.Account,base2.CustomerCode,base2.DueDate,base2.CurrencyCode,base2.ExchangeRate,base2.Amount,base2.Year,base2.AtchDocDate,base2.AtchDocNo,base2.IsActive,base2.CreatedAt,base2.account_group,base2.ad_is_active,base2.Posted,base2.DocStatus,base2.doc_year,base2.pdd_amount

)base3
	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_pt2 on base3.Id = pdd_pt2.ParentId and base3.PayType = 2

	-- where 1=1 and base3.Stt = 'B010000000269265'


	GROUP BY base3.Id,base3.Stt,base3.TransCode,base3.DocCode,base3.DocDate,base3.DocNo,base3.DocDateAcc,base3.DocNoAcc,base3.Description,base3.PayType,base3.IsPrepayment,base3.Account,base3.CustomerCode,base3.DueDate,base3.CurrencyCode,base3.ExchangeRate,base3.Amount,base3.Year,base3.AtchDocDate,base3.AtchDocNo,base3.IsActive,base3.CreatedAt,base3.account_group,base3.ad_is_active,base3.Posted,base3.DocStatus,base3.doc_year,base3.pdd_amount,base3.pdd_amount_extra

)base4
	
)base5
	
	GROUP BY base5.CustomerCode
,base5.account_group
,base5.PayType

ORDER BY base5.CustomerCode, base5.account_group ASC

;

Select pd.*
,pdd.*

from B7R2_VCP_TH.dbo.B30PayDoc pd
	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Id = pdd.ParentId

where  1=1
and pd.DocNo in ('TC-1194')
and pd.CustomerCode = 'B1127'

and pd.DocCode = 'BC'
and pd.DocNo like 'TC%'


--B1127
-- TC-1194
-- 2024-07-05 00:00:00
-- BC

;

Select base1.*
,bdk.*


from
	(select base.Stt
	,base.TransCode
	,base.DocCode
	,base.DocDate
	,base.DocNo
	,base.DocDateAcc
	,base.DocNoAcc
	,base.Description
	,base.PayType
	,base.IsPrepayment
	,base.Account
	,base.CustomerCode
	,base.DueDate
	,base.CurrencyCode
	,base.ExchangeRate
	,base.Amount
	,base.Year
	,base.AtchDocDate
	,base.AtchDocNo
	,base.IsActive
	,base.CreatedAt
	,base.account_group
	,base.ad_is_active
	,base.Posted
	,base.DocStatus
	,base.doc_year
--	,pdd_2.Amount
	,pdd_2.*
	--,sum(pdd_2.Amount) as pdd_amount




	from
		(Select pd.*
		,case when pd.Account like '131%' then '131'
			  when pd.Account like '331%' then '331'
			  else N'Others' end as account_group
		,ad.IsActive  as ad_is_active
		,ad.Posted
		,ad.DocStatus
		,year(pd.DocDate) as doc_year

		from B7R2_VCP_TH.dbo.B30PayDoc pd
			left join B7R2_VCP_TH.dbo.B30AccDoc ad on ad.Stt = pd.Stt and ad.CustomerCode = pd.CustomerCode
		--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Id = pdd.ParentId
		--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 on pd.Stt = pdd_2.Stt_Cd_Htt and pd.CustomerCode = pdd_2.CustomerCode

		where 1=1
		and isnull(ad.IsActive,1) = 1
		and (pd.IsOpenBalance = 0 OR (pd.IsOpenBalance = 1 and pd.Year = 2018)) 
		and pd.IsActive = 1 -- mới thêm

		
		)base
			left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 on base.Stt = pdd_2.Stt_Cd_Htt and base.CustomerCode = pdd_2.CustomerCode and pdd_2.IsActive = 1 and (pdd_2.Account LIKE '131%' OR pdd_2.Account LIKE '331%')
			
		--	Select * from B7R2_VCP_TH.dbo.B30PayDoc pd where pd.DocNo = 'PT-867' -- pd.Stt = 'B010000000102259'
		--	Select * from B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 where 1=1 and pdd_2.Stt_Cd_Htt = 'B010000000102259' and pdd_2.CustomerCode = 'B0054' and pdd_2.IsActive = 1 and (pdd_2.Account LIKE '131%' OR pdd_2.Account LIKE '331%')

		

	where 1=1
	and isnull(base.CustomerCode,'') <> ''
	and base.Stt not in ('B010000000177365')

	and base.CustomerCode = 'B0225'
	
	and base.DocNo = 'C24TCP14457'

	GROUP BY base.Stt,base.TransCode,base.DocCode,base.DocDate,base.DocNo,base.DocDateAcc,base.DocNoAcc,base.Description,base.PayType,base.IsPrepayment,base.Account,base.CustomerCode,base.DueDate,base.CurrencyCode,base.ExchangeRate,base.Amount,base.Year,base.AtchDocDate,base.AtchDocNo,base.IsActive,base.CreatedAt,base.account_group,base.ad_is_active,base.Posted,base.DocStatus,base.doc_year

	)base1
		left join (Select pd.Stt
					,pd.DocCode
					,case when pd.Stt = 'B0100000463962DK' then '2024-12-30' -- exceptional case chung tu C24TCP14457 co record DK bi lech 1 ngay (2024-12-31) so voi ngay dung (2024-12-31)
						else pd.DocDate end as DocDate
					,pd.DocNo
					,pd.Description
					,pd.Account
					,case when pd.Account like '131%' then '131'
						 when pd.Account like '331%' then '331'
						else N'Others' end as account_group
					,pd.PayType
					,pd.CustomerCode
					,pd.Amount
					,sum(pdd.Amount) as pdd_amount_for_dk
				
					--Select *
					from B7R2_VCP_TH.dbo.B30PayDoc pd-- where pd.Stt = 'B0100000259364DK'
						left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Stt = pdd.Stt_Cd_Htt and pd.CustomerCode = pdd.CustomerCode and pdd.IsActive = 1 and (pdd.Account LIKE '131%' OR pdd.Account LIKE '331%')
								
					where 1=1
					and pd.IsActive = 1
					and pd.Stt  like '%DK%'
					and pd.Stt not in ('B0100000288691DK','B0100000402427DK','B0100000350074DK','B0100000178532DK') -- exceptional cases / clean data
					--and year(pd.DocDate) >= 2018

					GROUP BY pd.Stt
							,pd.DocCode
							,pd.DocDate
							,pd.DocNo
							,pd.Description
							,pd.Account
							,pd.PayType
							,pd.CustomerCode
							,pd.Amount
							
					)bdk on bdk.DocCode = base1.DocCode and bdk.DocNo = base1.DocNo and bdk.CustomerCode = base1.CustomerCode and base1.DocDate = bdk.DocDate and bdk.Stt <> base1.Stt

-- GROUP BY base1.Stt,base1.TransCode,base1.DocCode,base1.DocDate,base1.DocNo,base1.DocDateAcc,base1.DocNoAcc,base1.Description,base1.PayType,base1.IsPrepayment,base1.Account,base1.CustomerCode,base1.DueDate,base1.CurrencyCode,base1.ExchangeRate,base1.Amount,base1.Year,base1.AtchDocDate,base1.AtchDocNo,base1.IsActive,base1.CreatedAt,base1.account_group,base1.ad_is_active,base1.Posted,base1.DocStatus,base1.doc_year,base1.pdd_amount


Where 1=1
and base1.CustomerCode = 'B0125'
and base1.DocNo = '0000430'

;

Select base2.Stt
,base2.DocDate
,base2.DocCode
,base2.PayType
,base2.CustomerCode
,base2.DocNo
,base2.Amount
,isnull(base2.pdd_amount,0) as pdd_amount
,isnull(base2.pdd_amount_extra,0) as pdd_amount_extra
,base2.Amount - isnull(base2.pdd_amount,0)  - isnull(base2.pdd_amount_extra,0) as test 

from
(Select base1.*
,sum(case -- when base1.Stt = 'B010000000225460' then 341999910 -- exceptional case: C24TCP692 co C24TCP1093 dieu chinh giam
		  when base1.Stt = 'B010000000096229' then 	33926407 -- exceptional case: 0005961 bi nham thanh 0005916 trong B0100000178513DK
		  when base1.Stt = 'B010000000096491' then 17999999 - 7852403 -- exceptional case: phieu goc da thanh toan 7852403, phieu DK B0100000178531DK lai thanh toan full
          when base1.Stt = 'B010000000110507' then 60890952 -- exceptionao case: M0217, docno 2020323
		  when base1.Stt = 'B010000000114043' then 2651971 -- exceptionao case: M0217, docno 2020323
		  when base1.Stt = 'B010000000206316' then 22259160.00 -- exceptionao case: M0217, docno P-149
		  when base1.Stt = 'B010000000206317' then 54458250.00 -- exceptionao case: M0217, docno P-150
		  when base1.Stt = 'B010000000223973' then 80322.00 -- exceptionao case: D0167, docno P-439
		else bdk.pdd_amount_for_dk end) as pdd_amount_extra

from
	(select base.Stt
	,base.TransCode
	,base.DocCode
	,base.DocDate
	,base.DocNo
	,base.DocDateAcc
	,base.DocNoAcc
	,base.Description
	,base.PayType
	,base.IsPrepayment
	,base.Account
	,base.CustomerCode
	,base.DueDate
	,base.CurrencyCode
	,base.ExchangeRate
	,base.Amount
	,base.Year
	,base.AtchDocDate
	,base.AtchDocNo
	,base.IsActive
	,base.CreatedAt
	,base.account_group
	,base.ad_is_active
	,base.Posted
	,base.DocStatus
	,base.doc_year
	,sum(pdd_2.Amount) as pdd_amount




	from
		(Select pd.*
		,case when pd.Account like '131%' then '131'
			  when pd.Account like '331%' then '331'
			  else N'Others' end as account_group
		,ad.IsActive  as ad_is_active
		,ad.Posted
		,ad.DocStatus
		,year(pd.DocDate) as doc_year

		from B7R2_VCP_TH.dbo.B30PayDoc pd
			left join B7R2_VCP_TH.dbo.B30AccDoc ad on ad.Stt = pd.Stt and ad.CustomerCode = pd.CustomerCode
		--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Id = pdd.ParentId
		--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 on pd.Stt = pdd_2.Stt_Cd_Htt and pd.CustomerCode = pdd_2.CustomerCode

		where 1=1
		and isnull(ad.IsActive,1) = 1
		and (pd.IsOpenBalance = 0 OR (pd.IsOpenBalance = 1 and pd.Year = 2018)) 
		and pd.IsActive = 1 -- mới thêm

		
		)base
			left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 on base.Stt = pdd_2.Stt_Cd_Htt and base.CustomerCode = pdd_2.CustomerCode and pdd_2.IsActive = 1 and (pdd_2.Account LIKE '131%' OR pdd_2.Account LIKE '331%') and base.Account = pdd_2.Account

		--	Select * from B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 where pdd_2.Stt_Cd_Htt = 'B0100000256108DK' and pdd_2.CustomerCode = 'M0217' and pdd_2.IsActive = 1 -- and base.Account = pdd_2.Account


	where 1=1
	and isnull(base.CustomerCode,'') <> ''
	and base.Stt not in ('B010000000177365')

	--and base.CustomerCode = 'B0023'
	--and base.DocNo = '0001242'

	GROUP BY base.Stt,base.TransCode,base.DocCode,base.DocDate,base.DocNo,base.DocDateAcc,base.DocNoAcc,base.Description,base.PayType,base.IsPrepayment,base.Account,base.CustomerCode,base.DueDate,base.CurrencyCode,base.ExchangeRate,base.Amount,base.Year,base.AtchDocDate,base.AtchDocNo,base.IsActive,base.CreatedAt,base.account_group,base.ad_is_active,base.Posted,base.DocStatus,base.doc_year

	)base1
		left join (Select pd.Stt
					,pd.DocCode
					,case when pd.Stt = 'B0100000463962DK' then '2024-12-30' -- exceptional case chung tu C24TCP14457 co record DK bi lech 1 ngay (2024-12-31) so voi ngay dung (2024-12-31)
						else pd.DocDate end as DocDate
					,pd.DocNo
					,pd.Description
					,pd.Account
					,case when pd.Account like '131%' then '131'
						 when pd.Account like '331%' then '331'
						else N'Others' end as account_group
					,pd.PayType
					,pd.CustomerCode
					,pd.Amount
					,sum(pdd.Amount) as pdd_amount_for_dk
				
					from B7R2_VCP_TH.dbo.B30PayDoc pd 
						left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Stt = pdd.Stt_Cd_Htt and pd.CustomerCode = pdd.CustomerCode and pdd.IsActive = 1 and (pdd.Account LIKE '131%' OR pdd.Account LIKE '331%') and pd.Account = pdd.Account

					--	Select * from B7R2_VCP_TH.dbo.B30PayDocDetail pdd where pdd.Stt_Cd_Htt = 'B010000000145353'
								
					where 1=1
					and pd.IsActive = 1
					and pd.Stt  like '%DK%'
					and pd.Stt not in ('B0100000288691DK','B0100000402427DK','B0100000350074DK','B0100000178532DK','B0100000351776DK','B0100000351413DK','B0100000180013DK') -- exceptional cases / clean data
				--	and pd.CustomerCode = 'B0001'
				--	and pd.Stt = 'A0100000001426DK'
					-- and year(pd.DocDate) >= 2018
					-- and ((year(pd.DocDate) >= 2018 and isnull(pd.DocNo,'') <> '') OR (year(pd.DocDate) < 2018 and isnull(pd.DocNo,'') = ''))

					GROUP BY pd.Stt
							,pd.DocCode
							,pd.DocDate
							,pd.DocNo
							,pd.Description
							,pd.Account
							,pd.PayType
							,pd.CustomerCode
							,pd.Amount
							
					)bdk on bdk.DocCode = base1.DocCode and bdk.DocNo = base1.DocNo and bdk.CustomerCode = base1.CustomerCode  and bdk.Stt <> base1.Stt and base1.DocDate = bdk.DocDate

GROUP BY base1.Stt,base1.TransCode,base1.DocCode,base1.DocDate,base1.DocNo,base1.DocDateAcc,base1.DocNoAcc,base1.Description,base1.PayType,base1.IsPrepayment,base1.Account,base1.CustomerCode,base1.DueDate,base1.CurrencyCode,base1.ExchangeRate,base1.Amount,base1.Year,base1.AtchDocDate,base1.AtchDocNo,base1.IsActive,base1.CreatedAt,base1.account_group,base1.ad_is_active,base1.Posted,base1.DocStatus,base1.doc_year,base1.pdd_amount


)base2

Where 1=1
 and base2.CustomerCode = 'B0277'
-- and base2.DocNo = 'CP/20E0000765'
-- and base2.PayType = 1
-- and base2.Stt = 'B0100000010121DK'
-- and base2.DocCode = 'HD'
-- and base2.Amount - isnull(base2.pdd_amount,0)  - isnull(base2.pdd_amount_extra,0) <> 0


ORDER BY base2.PayType ASC

;

