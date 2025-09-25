Select base.*
,sum(pdd.Amount) as amount_finished


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
--,ad.TotalAmount
,pd.Account
,pd.PayType -- 1: duong, 2: am, tuc la minh phai tra nguoi ta
,count(*) as total_recordby_stt
,sum(pd.Amount) as amount


--Select *
from
(Select * from (Select pd.Stt ,case when pd.Stt  like '%DK%' then 1 else 0 end as is_dk from B7R2_VCP_TH.dbo.B30PayDoc pd GROUP BY pd.Stt)b where 1=1 and b.is_dk = 0)b
	left join B7R2_VCP_TH.dbo.B30PayDoc pd on b.Stt = pd.Stt
	left join B7R2_VCP_TH.dbo.B00DmCt v_dmct on pd.DocCode = v_dmct.Ma_Ct
	left join B7R2_VCP_TH.dbo.B30AccDoc ad on ad.Stt = pd.Stt and ad.CustomerCode = pd.CustomerCode
--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Stt = pdd.Stt_Cd_Htt

Where 1=1
and (pd.CustomerCode LIKE 'B%' OR pd.CustomerCode LIKE 'M%')
and pd.IsActive = 1


GROUP BY pd.Stt,pd.DocCode,v_dmct.Ten_Ct,pd.CustomerCode,pd.CustomerCode,pd.DocDate,pd.DocNo,pd.DocDateAcc,pd.DocNoAcc,ad.DocNo,ad.DocSerialNo,pd.PayType,pd.Account
-- ORDER BY count(*) DESC

)base
	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on base.Stt = pdd.Stt_Cd_Htt and base.CustomerCode = pdd.CustomerCode



where 1=1
-- and base.amount <> base.TotalAmount
-- and base.DocNo in ('VT-0236','VT-135')
--and base.DocNo = 'TC-090'
-- and base.DocCode = 'NM'
-- and base.CustomerCode in ('B0081')
-- and base.DocDate between '2020-03-31' and '2020-03-31'
-- and base.ad_doc_no = 'NM/21/00239'
-- and pd.Account like '331%'
-- and base.PayType = 2

-- GROUP BY base.DocCode,base.Ten_Ct
-- ORDER BY base.CustomerCode ASC

GROUP BY base.Stt
,base.DocCode
,base.Ten_Ct
,base.CustomerCode
,base.DocDate
,base.DocNo
,base.DocDateAcc
,base.DocNoAcc
,base.ad_doc_no
,base.DocSerialNo
,base.total_recordby_stt
,base.amount
,base.PayType
,base.Account

;

Select base.*
,sum(pdd.Amount) as amount_finished


from
(Select pd.Stt
,pd.DocCode
,v_dmct.Ten_Ct
,pd.CustomerCode
,pd.DocDate
,pd.DocNo
,pd.DocDateAcc
,pd.DocNoAcc
--,ad.DocNo as ad_doc_no
--,ad.DocSerialNo
--,ad.TotalAmount
,pd.Account
,pd.PayType -- 1: duong, 2: am, tuc la minh phai tra nguoi ta
,count(*) as total_recordby_stt
,sum(pd.Amount) as amount


--Select *
from
(Select * from (Select pd.Stt ,case when pd.Stt  like '%DK%' then 1 else 0 end as is_dk from B7R2_VCP_TH.dbo.B30PayDoc pd GROUP BY pd.Stt)b where 1=1 and b.is_dk = 1)b
	left join B7R2_VCP_TH.dbo.B30PayDoc pd on b.Stt = pd.Stt
	left join B7R2_VCP_TH.dbo.B00DmCt v_dmct on pd.DocCode = v_dmct.Ma_Ct
--	left join B7R2_VCP_TH.dbo.B30AccDoc ad on ad.Stt = pd.Stt
--	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on pd.Stt = pdd.Stt_Cd_Htt

Where 1=1
-- and pd.DocNo = 'C23TCP8960'
--and ad.IsActive = 1
--and ad.Posted = 1
--and ad.DocStatus = 4 -- đã hoàn thiện
and (pd.CustomerCode LIKE 'B%' OR pd.CustomerCode LIKE 'M%')
--and isnull(ad.CustomerCode,'') = ''
--and (ad.CustomerCode LIKE 'B%' OR ad.CustomerCode LIKE 'M%')
and pd.Stt in ('A0100000001566DK','A0100000001567DK')

GROUP BY pd.Stt,pd.DocCode,v_dmct.Ten_Ct,pd.CustomerCode,pd.CustomerCode,pd.DocDate,pd.DocNo,pd.DocDateAcc,pd.DocNoAcc,pd.PayType,pd.Account
-- ORDER BY count(*) DESC

)base
	left join B7R2_VCP_TH.dbo.B30PayDocDetail pdd on base.Stt = pdd.Stt_Cd_Htt and base.CustomerCode = pdd.CustomerCode


where 1=1
-- and base.amount <> base.TotalAmount
-- and base.DocNo in ('VT-0236','VT-135')
-- and base.DocNo = 'TC-090'
-- and base.DocCode = 'NM'
and base.CustomerCode in ('B0081')
-- and base.DocDate between '2020-03-31' and '2020-03-31'
-- and base.ad_doc_no = 'NM/21/00239'
-- and pd.Account like '331%'
-- and base.PayType = 2

-- GROUP BY base.DocCode,base.Ten_Ct
-- ORDER BY base.CustomerCode ASC

GROUP BY base.Stt
,base.DocCode
,base.Ten_Ct
,base.CustomerCode
,base.DocDate
,base.DocNo
,base.DocDateAcc
,base.DocNoAcc

,base.total_recordby_stt
,base.amount
,base.PayType
,base.Account

ORDER BY base.DocNo ASC