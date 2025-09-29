select  base.CustomerCode
,sum(case when base.account_group = '331' and base.PayType = 1 then base.Amount
		  when base.account_group = '331' and base.PayType = 2 then (-1)*base.Amount
		  when base.account_group = '131' and base.PayType = 1 then (-1)*base.Amount
		  when base.account_group = '131' and base.PayType = 2 then base.Amount
		  else base.Amount end) as total

from
(Select pd.*
--,pdd.*
--,pdd_2.*
--,pdd.Amount
--,pdd.Stt
--,pdd.Stt_Cd_Htt
--,pdd_2.Amount
--,pdd_2.Stt
--,pdd_2.Stt_Cd_Htt
--,pdd.ParentId
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
-- and pd.Stt in ('B010000000146355','B010000000146391')
--		and DocCode= 'PK'
--		and DocNo= '00003123'
	--	and pd.CustomerCode= 'B0207'
	--	and pd.Year = 2018
		and isnull(ad.IsActive,1) = 1
		and (pd.IsOpenBalance = 0 OR (pd.IsOpenBalance = 1 and pd.Year = 2018)) 
		
		and pd.IsActive = 1 -- mới thêm

	--	and (year(pd.DocDate) <= 2018 OR (year(pd.DocDate) > 2018 and ad.IsActive =1))
	--	and year(pd.DocDate) >= 2018
	--	and pd.IsOpenBalance = 1
		
)base

where 1=1
and isnull(base.CustomerCode,'') <> ''

GROUP BY base.CustomerCode
;

Select sum(case when base2.account_group = '331' and base2.PayType = 1 then base2.Amount
		  when base2.account_group = '331' and base2.PayType = 2 then (-1)*base2.Amount
		  when base2.account_group = '131' and base2.PayType = 1 then (-1)*base2.Amount
		  when base2.account_group = '131' and base2.PayType = 2 then base2.Amount
		  else base2.Amount end) as total
,sum(case when base2.account_group = '331' and base2.PayType = 1 then base2.pdd_amount
		  when base2.account_group = '331' and base2.PayType = 2 then (-1)*base2.pdd_amount
		  when base2.account_group = '131' and base2.PayType = 1 then (-1)*base2.pdd_amount
		  when base2.account_group = '131' and base2.PayType = 2 then base2.pdd_amount
		  else base2.pdd_amount end) as total_pdd


from

(Select base1.Stt
,base1.CustomerCode
,base1.PayType
,base1.DocDate
,base1.DocCode
,base1.DocNo
,base1.Account
,base1.account_group
,base1.Amount
,base1.pdd_amount

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
	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 on base.Stt = pdd_2.Stt_Cd_Htt and base.CustomerCode = pdd_2.CustomerCode

where 1=1
and isnull(base.CustomerCode,'') <> ''

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

)base2