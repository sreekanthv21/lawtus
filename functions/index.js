
const functions= require("firebase-functions/v2/https");
const admin=require("firebase-admin");

admin.initializeApp();
exports.functogetlivetime=functions.onCall((req)=>{
  try {
    const time=new Date().toLocaleString("sv-SE", {
      timeZone: "Asia/Kolkata",
      hour12: false,
    }).replace(" ", "T");
    return {
      time: time,
    };
  } catch (e) {
    return {
      error: "error",
    };
  }
});

