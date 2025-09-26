Select base.*
--,pdd.*


from
(Select pd.Stt
,pd.DocCode
,v_dmct.Ten_Ct
,pd.CustomerCode
,pd.DocDate
,pd.DocNo
,pd.DocDateAcc
,pd.DocNoAcc
,ad.DocNo as ad_doc_no
,ad.DocSerialNo
,ad.TotalAmount
,pd.PayType -- 1: duong, 2: am, tuc la minh phai tra nguoi ta
,count(*) as total_recordby_stt
,sum(pd.Amount) as amount


--Select *
from
(Select * from (Select pd.Stt ,case when pd.Stt  like '%DK%' then 1 else 0 end as is_dk from B7R2_VCP_TH.dbo.B30PayDoc pd GROUP BY pd.Stt)b where 1=1 and b.is_dk = 0)b
	left join B7R2_VCP_TH.dbo.B30PayDoc pd on b.Stt = pd.Stt
	left join B7R2_VCP_TH.dbo.B00DmCt v_dmct on pd.DocCode = v_dmct.Ma_Ct
	left join B7R2_VCP_TH.dbo.B30AccDoc ad on ad.Stt = pd.Stt
--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Stt = pdd.Stt_Cd_Htt

Where 1=1
-- and pd.DocNo = 'C23TCP8960'
and ad.IsActive = 1
and ad.Posted = 1
and ad.DocStatus = 4 -- đã hoàn thiện
and (pd.CustomerCode LIKE 'B%' OR pd.CustomerCode LIKE 'M%')
--and isnull(ad.CustomerCode,'') = ''
--and (ad.CustomerCode LIKE 'B%' OR ad.CustomerCode LIKE 'M%')
--and pd.Stt = 'A010000000000812'

GROUP BY pd.Stt,pd.DocCode,v_dmct.Ten_Ct,pd.CustomerCode,pd.CustomerCode,pd.DocDate,pd.DocNo,pd.DocDateAcc,pd.DocNoAcc,ad.DocNo,ad.DocSerialNo,ad.TotalAmount,pd.PayType
-- ORDER BY count(*) DESC

)base
--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on base.Stt = pdd.Stt_Cd_Htt
left join B7R2_VCP_TH.dbo.B30PayDoc pd on base.Stt = pd.Stt

where 1=1
-- and base.amount <> base.TotalAmount
-- and base.DocNo = 'C24TCP14088'
--and base.DocNo = 'VT-1006'
 and base.DocCode = 'HD'
 and base.CustomerCode = 'B0294'
 and base.DocDate between '2024-01-01' and '2024-12-31'

 ;


 select sum(case when base.PayType = 2 then -1*base.Amount else base.Amount end)

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
		and pd.CustomerCode= 'M0089'
--		and pd.Year = 2025
		and isnull(ad.IsActive,1) = 1
		and pd.IsOpenBalance = 0
)base