select  base.CustomerCode
,case when base.account_group = '331' and base.PayType = 1 then base.Amount
		  when base.account_group = '331' and base.PayType = 2 then (-1)*base.Amount
		  when base.account_group = '131' and base.PayType = 1 then (-1)*base.Amount
		  when base.account_group = '131' and base.PayType = 2 then base.Amount
		  else base.Amount end amount_new
,base.*

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

from B7R2_VCP_TH.dbo.B30PayDoc pd
	left join B7R2_VCP_TH.dbo.B30AccDoc ad on ad.Stt = pd.Stt and ad.CustomerCode = pd.CustomerCode
--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Id = pdd.ParentId
--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 on pd.Stt = pdd_2.Stt_Cd_Htt and pd.CustomerCode = pdd_2.CustomerCode

where 1=1
-- and pd.Stt in ('B010000000146355','B010000000146391')
--		and DocCode= 'PK'
--		and DocNo= '00003123'
		and pd.CustomerCode= 'M0215'
--		and pd.Year = 2025
		and isnull(ad.IsActive,1) = 1
		and (pd.IsOpenBalance = 0 OR (pd.IsOpenBalance = 1 and pd.Year = 2018))   
	--	and pd.IsOpenBalance = 1
		
)base


;

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

from B7R2_VCP_TH.dbo.B30PayDoc pd
	left join B7R2_VCP_TH.dbo.B30AccDoc ad on ad.Stt = pd.Stt and ad.CustomerCode = pd.CustomerCode
--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Id = pdd.ParentId
--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 on pd.Stt = pdd_2.Stt_Cd_Htt and pd.CustomerCode = pdd_2.CustomerCode

where 1=1
-- and pd.Stt in ('B010000000146355','B010000000146391')
--		and DocCode= 'PK'
--		and DocNo= '00003123'
	--	and pd.CustomerCode= 'M0167'
	--	and pd.Year = 2018
		and isnull(ad.IsActive,1) = 1
		and (pd.IsOpenBalance = 0 OR (pd.IsOpenBalance = 1 and pd.Year = 2018))   
	--	and pd.IsOpenBalance = 1
		
)base

GROUP BY base.CustomerCode

;

select base.account_group
,base.PayType
,sum(base.Amount) as amount

 -- sum(case when base.PayType = 2 then -1*base.Amount else base.Amount end)

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

from B7R2_VCP_TH.dbo.B30PayDoc pd
	left join B7R2_VCP_TH.dbo.B30AccDoc ad on ad.Stt = pd.Stt and ad.CustomerCode = pd.CustomerCode
--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Id = pdd.ParentId
--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd_2 on pd.Stt = pdd_2.Stt_Cd_Htt and pd.CustomerCode = pdd_2.CustomerCode

where 1=1
-- and pd.Stt in ('B010000000146355','B010000000146391')
--		and DocCode= 'PK'
--		and DocNo= '00003123'
--		and pd.CustomerCode= 'M0221'
--		and pd.Year = 2025
		and isnull(ad.IsActive,1) = 1
		and (pd.IsOpenBalance = 0 OR (pd.IsOpenBalance = 1 and pd.Year = 2018))   
	--	and pd.IsOpenBalance = 1
		
)base

GROUP By base.account_group
,base.PayType
