.pragma library

var looks = [
 {id:"natural",swatch:"#e0d9cf"},
 {id:"mono",swatch:"#888888",saturation:-1},
 {id:"noir",swatch:"#292929",saturation:-1,contrast:.25,brightness:-.05},
 {id:"silver",swatch:"#b4bcc4",saturation:-1,contrast:.12,brightness:.04},
 {id:"sepia",swatch:"#9f764c",saturation:-.8,tint:"#b79565",colorization:.55},
 {id:"warm",swatch:"#f0b58a",tint:"#f4b47c",colorization:.12,brightness:.03,saturation:.05},
 {id:"cool",swatch:"#93b9d7",tint:"#7398d9",colorization:.09,saturation:-.12},
 {id:"pastel",swatch:"#d8c7df",brightness:.08,saturation:-.28,contrast:-.08},
 {id:"vivid",swatch:"#fc719c",saturation:.45,brightness:.02},
 {id:"cinema",swatch:"#608c88",saturation:-.18,contrast:.14,brightness:-.03},
 {id:"fade",swatch:"#c9bea6",brightness:.08,contrast:-.12},
 {id:"rose",swatch:"#f1aec2",tint:"#f1aec2",colorization:.12},
 {id:"amber",swatch:"#f4bf78",tint:"#f4bf78",colorization:.12},
 {id:"mint",swatch:"#89cbb5",tint:"#89cbb5",colorization:.09},
 {id:"blue",swatch:"#829ed7",tint:"#829ed7",colorization:.14},
 {id:"lavender",swatch:"#b8a1df",tint:"#b8a1df",colorization:.12},
 {id:"glow",swatch:"#f5e4bc",brightness:.08,contrast:.06,saturation:-.05},
 {id:"crisp",swatch:"#afc9c9",contrast:.15,saturation:.10}
];
function profile(name) {
 for(var i=0;i<looks.length;i++)if(looks[i].id===name)return looks[i];
 return looks[0];
}
