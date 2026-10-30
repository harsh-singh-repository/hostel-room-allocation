package com.hostel.model;

import java.math.BigDecimal;
import java.util.Date;

public class Payment {
    private int payId;
    private int allocId;
    private BigDecimal amount;
    private String payMode;
    private String txnRef;
    private Date paidOn;

    public int getPayId() { return payId; }
    public void setPayId(int payId) { this.payId = payId; }
    public int getAllocId() { return allocId; }
    public void setAllocId(int allocId) { this.allocId = allocId; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getPayMode() { return payMode; }
    public void setPayMode(String payMode) { this.payMode = payMode; }
    public String getTxnRef() { return txnRef; }
    public void setTxnRef(String txnRef) { this.txnRef = txnRef; }
    public Date getPaidOn() { return paidOn; }
    public void setPaidOn(Date paidOn) { this.paidOn = paidOn; }
}
