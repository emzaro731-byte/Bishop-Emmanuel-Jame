const products=[
{name:"Handbags",category:"Bags",icon:"👜"},
{name:"Wrist Watches",category:"Watches",icon:"⌚"},
{name:"Jewelry",category:"Jewelry",icon:"💎"},
{name:"Sunglasses",category:"Sunglasses",icon:"🕶️"},
{name:"Belts",category:"Accessories",icon:"◈"},
{name:"Fashion Accessories",category:"Accessories",icon:"✦"}
];
const root=document.querySelector("#products"),search=document.querySelector("#search");let filter="all";
function wa(item){return "https://wa.me/2348140499272?text="+encodeURIComponent("Hello Laz B Empire, I'm interested in "+item+". Please send me available options and prices.");}
function render(){
 const q=search.value.trim().toLowerCase();
 const list=products.filter(p=>(filter==="all"||p.category===filter)&&(!q||p.name.toLowerCase().includes(q)||p.category.toLowerCase().includes(q)));
 root.innerHTML=list.map(p=>'<article class="product"><div class="product-art" aria-hidden="true">'+p.icon+'<small>'+p.category+'</small></div><h3>'+p.name+'</h3><p>Price and availability on request</p><a href="'+wa(p.name)+'" target="_blank" rel="noopener">Ask on WhatsApp →</a></article>').join("")||'<p>No matching items. Try another search.</p>';
}
document.querySelectorAll(".chip").forEach(btn=>btn.addEventListener("click",()=>{filter=btn.dataset.filter;document.querySelectorAll(".chip").forEach(b=>b.classList.remove("active"));btn.classList.add("active");render();}));
search.addEventListener("input",render);
document.querySelector("#menuBtn").addEventListener("click",()=>{const nav=document.querySelector("#navMenu");const open=nav.classList.toggle("open");document.querySelector("#menuBtn").setAttribute("aria-expanded",open);});
document.querySelectorAll("#navMenu a").forEach(a=>a.addEventListener("click",()=>document.querySelector("#navMenu").classList.remove("open")));
document.querySelector("#orderForm").addEventListener("submit",e=>{e.preventDefault();const name=document.querySelector("#customerName").value.trim(),item=document.querySelector("#itemChoice").value,type=document.querySelector("#orderType").value;const msg="Hello Laz B Empire, my name is "+name+". I want to ask about "+item+". Preference: "+type+". Please send me the available options and price.";window.open("https://wa.me/2348140499272?text="+encodeURIComponent(msg),"_blank");});
document.querySelector("#year").textContent=new Date().getFullYear();render();