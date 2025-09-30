Select base2.*
,isnull(base2.total_pdd,0) +  isnull(base2.pdd_amount_extra,0) as final_pdd
,isnull(base2.total_pdd,0) +  isnull(base2.pdd_amount_extra,0) - isnull(base2.total,0) as test

from
(Select base1.DocCode,base1.DocNo

--base1.CustomerCode
--,base1.account_group
,base1.PayType

,sum(case when base1.account_group = '331' and base1.PayType = 1 then base1.Amount
		  when base1.account_group = '331' and base1.PayType = 2 then (-1)*base1.Amount
		  when base1.account_group = '131' and base1.PayType = 1 then (-1)*base1.Amount
		  when base1.account_group = '131' and base1.PayType = 2 then base1.Amount
		  else base1.Amount end) as total
,sum(case when base1.account_group = '331' and base1.PayType = 1 then base1.pdd_amount
		  when base1.account_group = '331' and base1.PayType = 2 then (-1)*base1.pdd_amount
		  when base1.account_group = '131' and base1.PayType = 1 then (-1)*base1.pdd_amount
		  when base1.account_group = '131' and base1.PayType = 2 then base1.pdd_amount
		  else base1.pdd_amount end) as total_pdd
,sum(base1.pdd_amount_extra) as pdd_amount_extra




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
,sum(case when bdk.account_group = '331' and bdk.PayType = 1 then bdk.pdd_amount_for_dk
		  when bdk.account_group = '331' and bdk.PayType = 2 then (-1)*bdk.pdd_amount_for_dk
		  when bdk.account_group = '131' and bdk.PayType = 1 then (-1)*bdk.pdd_amount_for_dk
		  when bdk.account_group = '131' and bdk.PayType = 2 then bdk.pdd_amount_for_dk
		  else bdk.Amount end) as pdd_amount_extra



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
	left join (Select * from (Select pd.Stt
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
					left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Stt = pdd.Stt_Cd_Htt and pd.CustomerCode = pdd.CustomerCode and pdd.IsActive = 1 and (pdd.Account LIKE '131%' OR pdd.Account LIKE '331%')
								
				where 1=1
				and pd.IsActive = 1
				and pd.Stt  like '%DK%'

				GROUP BY pd.Stt
						,pd.DocCode
						,pd.DocDate
						,pd.DocNo
						,pd.Description
						,pd.Account
						,pd.PayType
						,pd.CustomerCode
						,pd.Amount

				)b 
				
				)bdk on bdk.DocCode = base.DocCode and bdk.DocNo = base.DocNo and bdk.CustomerCode = base.CustomerCode


where 1=1
and isnull(base.CustomerCode,'') <> ''
and base.Stt not in ('B010000000177365')

GROUP BY base.Stt
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


)base1

where 1=1
and base1.CustomerCode = 'B0001'
--and base1.DocNo = 'CP/20E0000599'

GROUP BY --base1.CustomerCode
--,base1.account_group

base1.DocCode,base1.DocNo
,base1.PayType
)base2

ORDER BY base2.PayType ASC


;


















Select pd.*
,case when pd.Account like '131%' then '131'
	  when pd.Account like '331%' then '331'
	  else N'Others' end as account_group
,ad.IsActive  as ad_is_active
,ad.Posted
,ad.DocStatus
,year(pd.DocDate) as doc_year
,pdd_2.*

from B7R2_VCP_TH.dbo.B30PayDoc pd
	left join B7R2_VCP_TH.dbo.B30AccDoc ad on ad.Stt = pd.Stt and ad.CustomerCode = pd.CustomerCode
--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Id = pdd.ParentId
	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 on pd.Stt = pdd_2.Stt_Cd_Htt and pd.CustomerCode = pdd_2.CustomerCode and (pdd_2.Account LIKE '131%' OR pdd_2.Account LIKE '331%')

where 1=1
--and isnull(ad.IsActive,1) = 1
--and (pd.IsOpenBalance = 0 OR (pd.IsOpenBalance = 1 and pd.Year = 2018)) 
--and pd.IsActive = 1 -- mới thêm
and pd.CustomerCode = 'B0001'
--and pd.Stt like '%DK'
and pd.DocNo in ('0000955')