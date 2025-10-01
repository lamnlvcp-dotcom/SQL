Select base2.CustomerCode
,base2.account_group
,base2.PayType
--,base2.DocNo
,sum(case when base2.account_group = '331' and base2.PayType = 1 then isnull(base2.Amount,0)
		  when base2.account_group = '331' and base2.PayType = 2 then (-1)*isnull(base2.Amount,0)
		  when base2.account_group = '131' and base2.PayType = 1 then (-1)*isnull(base2.Amount,0)
		  when base2.account_group = '131' and base2.PayType = 2 then isnull(base2.Amount,0)
		  else isnull(base2.Amount,0) end) as total

,sum(case when base2.account_group = '331' and base2.PayType = 1 then isnull(base2.pdd_amount,0)
		  when base2.account_group = '331' and base2.PayType = 2 then (-1)*isnull(base2.pdd_amount,0)
		  when base2.account_group = '131' and base2.PayType = 1 then (-1)*isnull(base2.pdd_amount,0)
		  when base2.account_group = '131' and base2.PayType = 2 then isnull(base2.pdd_amount,0)
		  else isnull(base2.pdd_amount,0) end) as total_pdd
,sum(isnull(base2.pdd_amount_extra,0)) as pdd_amount_extra

,sum(case when base2.account_group = '331' and base2.PayType = 1 then isnull(base2.pdd_amount,0)
		  when base2.account_group = '331' and base2.PayType = 2 then (-1)*isnull(base2.pdd_amount,0)
		  when base2.account_group = '131' and base2.PayType = 1 then (-1)*isnull(base2.pdd_amount,0)
		  when base2.account_group = '131' and base2.PayType = 2 then isnull(base2.pdd_amount,0)
		  else isnull(base2.pdd_amount,0) end) + sum(isnull(base2.pdd_amount_extra,0)) as test

from
(Select base1.*
,sum(case when bdk.account_group = '331' and bdk.PayType = 1 then bdk.pdd_amount_for_dk
		  when bdk.account_group = '331' and bdk.PayType = 2 then (-1)*bdk.pdd_amount_for_dk
		  when bdk.account_group = '131' and bdk.PayType = 1 then (-1)*bdk.pdd_amount_for_dk
		  when bdk.account_group = '131' and bdk.PayType = 2 then bdk.pdd_amount_for_dk
		  else bdk.Amount end) as pdd_amount_extra

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

	where 1=1
	and isnull(base.CustomerCode,'') <> ''
	and base.Stt not in ('B010000000177365')

	--and base.CustomerCode = 'B0023'
	--and base.DocNo = '0001242'

	GROUP BY base.Stt,base.TransCode,base.DocCode,base.DocDate,base.DocNo,base.DocDateAcc,base.DocNoAcc,base.Description,base.PayType,base.IsPrepayment,base.Account,base.CustomerCode,base.DueDate,base.CurrencyCode,base.ExchangeRate,base.Amount,base.Year,base.AtchDocDate,base.AtchDocNo,base.IsActive,base.CreatedAt,base.account_group,base.ad_is_active,base.Posted,base.DocStatus,base.doc_year

	)base1
		left join (Select pd.Stt
					,pd.DocCode
					,pd.DocDate
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
					and year(pd.DocDate) >= 2018
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
							
					)bdk on bdk.DocCode = base1.DocCode and bdk.DocNo = base1.DocNo and bdk.CustomerCode = base1.CustomerCode and base1.DocDate = bdk.DocDate

GROUP BY base1.Stt,base1.TransCode,base1.DocCode,base1.DocDate,base1.DocNo,base1.DocDateAcc,base1.DocNoAcc,base1.Description,base1.PayType,base1.IsPrepayment,base1.Account,base1.CustomerCode,base1.DueDate,base1.CurrencyCode,base1.ExchangeRate,base1.Amount,base1.Year,base1.AtchDocDate,base1.AtchDocNo,base1.IsActive,base1.CreatedAt,base1.account_group,base1.ad_is_active,base1.Posted,base1.DocStatus,base1.doc_year,base1.pdd_amount


)base2

Where 1=1
 and base2.CustomerCode = 'B0120'

GROUP BY base2.CustomerCode
,base2.account_group
,base2.PayType
--,base2.DocNo

ORDER BY base2.CustomerCode, base2.PayType ASC

;



Select base2.Stt
,base2.DocDate
,base2.PayType
,base2.CustomerCode
,base2.DocNo
,base2.Amount
,isnull(base2.pdd_amount,0) as pdd_amount
,isnull(base2.pdd_amount_extra,0) as pdd_amount_extra
,base2.Amount - isnull(base2.pdd_amount,0)  - isnull(base2.pdd_amount_extra,0) as test 

from
(Select base1.*
,sum(bdk.pdd_amount_for_dk) as pdd_amount_extra

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

	where 1=1
	and isnull(base.CustomerCode,'') <> ''
	and base.Stt not in ('B010000000177365')

	--and base.CustomerCode = 'B0023'
	--and base.DocNo = '0001242'

	GROUP BY base.Stt,base.TransCode,base.DocCode,base.DocDate,base.DocNo,base.DocDateAcc,base.DocNoAcc,base.Description,base.PayType,base.IsPrepayment,base.Account,base.CustomerCode,base.DueDate,base.CurrencyCode,base.ExchangeRate,base.Amount,base.Year,base.AtchDocDate,base.AtchDocNo,base.IsActive,base.CreatedAt,base.account_group,base.ad_is_active,base.Posted,base.DocStatus,base.doc_year

	)base1
		left join (Select pd.Stt
					,pd.DocCode
					,pd.DocDate
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
					and pd.CustomerCode = 'B0120'
					--and year(pd.DocDate) >= 2018
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
							
					)bdk on bdk.DocCode = base1.DocCode and bdk.DocNo = base1.DocNo and bdk.CustomerCode = base1.CustomerCode and base1.DocDate = bdk.DocDate

GROUP BY base1.Stt,base1.TransCode,base1.DocCode,base1.DocDate,base1.DocNo,base1.DocDateAcc,base1.DocNoAcc,base1.Description,base1.PayType,base1.IsPrepayment,base1.Account,base1.CustomerCode,base1.DueDate,base1.CurrencyCode,base1.ExchangeRate,base1.Amount,base1.Year,base1.AtchDocDate,base1.AtchDocNo,base1.IsActive,base1.CreatedAt,base1.account_group,base1.ad_is_active,base1.Posted,base1.DocStatus,base1.doc_year,base1.pdd_amount


)base2

Where 1=1
and base2.CustomerCode = 'B0120'
-- and base2.DocNo = 'CP/20E0000765'
and base2.PayType = 1
and base2.Stt = 'B0100000010121DK'
-- and base2.Amount - isnull(base2.pdd_amount,0)  - isnull(base2.pdd_amount_extra,0) <> 0


ORDER BY base2.PayType ASC


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

	and base.CustomerCode = 'B0120'
	
	and base.DocNo = '0000430'

	GROUP BY base.Stt,base.TransCode,base.DocCode,base.DocDate,base.DocNo,base.DocDateAcc,base.DocNoAcc,base.Description,base.PayType,base.IsPrepayment,base.Account,base.CustomerCode,base.DueDate,base.CurrencyCode,base.ExchangeRate,base.Amount,base.Year,base.AtchDocDate,base.AtchDocNo,base.IsActive,base.CreatedAt,base.account_group,base.ad_is_active,base.Posted,base.DocStatus,base.doc_year

	)base1
		left join (Select pd.Stt
					,pd.DocCode
					,pd.DocDate
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
					and year(pd.DocDate) >= 2018

					GROUP BY pd.Stt
							,pd.DocCode
							,pd.DocDate
							,pd.DocNo
							,pd.Description
							,pd.Account
							,pd.PayType
							,pd.CustomerCode
							,pd.Amount
							
					)bdk on bdk.DocCode = base1.DocCode and bdk.DocNo = base1.DocNo and bdk.CustomerCode = base1.CustomerCode and base1.DocDate = bdk.DocDate

-- GROUP BY base1.Stt,base1.TransCode,base1.DocCode,base1.DocDate,base1.DocNo,base1.DocDateAcc,base1.DocNoAcc,base1.Description,base1.PayType,base1.IsPrepayment,base1.Account,base1.CustomerCode,base1.DueDate,base1.CurrencyCode,base1.ExchangeRate,base1.Amount,base1.Year,base1.AtchDocDate,base1.AtchDocNo,base1.IsActive,base1.CreatedAt,base1.account_group,base1.ad_is_active,base1.Posted,base1.DocStatus,base1.doc_year,base1.pdd_amount


Where 1=1
and base1.CustomerCode = 'B0125'
and base1.DocNo = '0000430'





-- ORDER BY base2.CustomerCode, base2.PayType ASC

;


Select *

from B7R2_VCP_TH.dbo.B30PayDoc pd

where  1=1
and pd.Stt in ('A0100000001645DK','A0100000001646DK')