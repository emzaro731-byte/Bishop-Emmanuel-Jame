const products=[
{name:"iPhone 15 Pro",category:"Phones",price:1250000,icon:"📱",description:"Premium Apple smartphone with Pro performance."},
{name:"Samsung Galaxy S24",category:"Phones",price:980000,icon:"📱",description:"Flagship Android phone with a bright display and great camera."},
{name:"AirPods Pro",category:"Accessories",price:320000,icon:"🎧",description:"Wireless earbuds with active noise cancellation."},
{name:"MacBook Air M2",category:"Laptops",price:1450000,icon:"💻",description:"Lightweight laptop for work, school and creativity."},
{name:"Power Bank 20,000mAh",category:"Accessories",price:45000,icon:"🔋",description:"High-capacity portable power for your devices."},
{name:"Gaming Headset",category:"Gaming",price:65000,icon:"🎮",description:"Comfortable headset for gaming and entertainment."}
];
const categories=["All","Phones","Laptops","Accessories","Gaming"];
let category="All",cart=[];
const money=n=>"₦"+n.toLocaleString("en-NG");
const $=id=>document.getElementById(id);

function renderCategories(){
 $("categories").innerHTML=categories.map(c=>`<button class="chip ${c===category?"active":""}" data-category="${c}">${c}</button>`).join("");
 document.querySelectorAll("[data-category]").forEach(b=>b.onclick=()=>{category=b.dataset.category;renderCategories();renderProducts()});
}
function renderProducts(){
 const q=$("searchInput").value.trim().toLowerCase();
 const list=products.filter(p=>(category==="All"||p.category===category)&&(!q||p.name.toLowerCase().includes(q)||p.category.toLowerCase().includes(q)));
 $("itemCount").textContent=list.length+" items";
 $("products").innerHTML=list.map((p,i)=>`<article class="product">
  <div class="product-visual">${p.icon}</div>
  <h3>${p.name}</h3><div class="category">${p.category}</div><div class="price">${money(p.price)}</div>
  <button class="add" data-add="${products.indexOf(p)}">Add</button>
 </article>`).join("")||'<div style="grid-column:1/-1;text-align:center;padding:35px;color:#6f6b75">No matching products found.</div>';
 document.querySelectorAll("[data-add]").forEach(b=>b.onclick=()=>addToCart(Number(b.dataset.add)));
 document.querySelectorAll(".product").forEach((el,i)=>{el.onclick=e=>{if(!e.target.matches("button"))showProduct(list[i])}});
}
function addToCart(i){cart.push(products[i]);updateBadge();showMessage(products[i].name+" added to cart")}
function updateBadge(){$("cartBadge").textContent=cart.length;$("cartBadge").classList.toggle("hidden",cart.length===0)}
function showMessage(msg){openModal(`<h2>Added to cart</h2><p>${msg}</p><div class="modal-actions"><button class="primary" onclick="closeModal()">Continue shopping</button><button class="secondary" onclick="showCart()">View cart</button></div>`)}
function showProduct(p){openModal(`<h2>${p.name}</h2><p>${p.description}</p><p><b>Category:</b> ${p.category}<br><b>Price:</b> ${money(p.price)}</p><div class="modal-actions"><button class="secondary" onclick="closeModal()">Close</button><button class="primary" onclick="addToCart(${products.indexOf(p)});closeModal()">Add to cart</button></div>`)}
function showCart(){
 if(!cart.length){openModal('<h2>Shopping cart</h2><p>Your cart is empty.</p><div class="modal-actions"><button class="primary" onclick="closeModal()">Continue shopping</button></div>');return}
 const total=cart.reduce((s,p)=>s+p.price,0);
 openModal(`<h2>Shopping cart</h2>${cart.map(p=>`<div class="cart-row"><b>${p.name}</b><span>${money(p.price)}</span></div>`).join("")}<div class="total"><span>Total</span><span>${money(total)}</span></div><div class="modal-actions"><button class="secondary" onclick="closeModal()">Continue</button><button class="primary" onclick="checkout()">Proceed to checkout</button></div>`)
}
function checkout(){openModal('<h2>Demo checkout</h2><p>This website is a sales demo. A production version can connect Paystack or Flutterwave, delivery, inventory and order management.</p><div class="modal-actions"><button class="primary" onclick="closeModal()">Done</button></div>')}
function openModal(html){$("modalCard").innerHTML=html;$("modal").classList.remove("hidden")}
function closeModal(){$("modal").classList.add("hidden")}
$("modal").querySelector(".backdrop").onclick=closeModal;
$("cartBtn").onclick=showCart;
$("searchInput").oninput=renderProducts;
$("storeBtn").onclick=()=>openModal('<h2>EBENS GADGET UNIVERSE</h2><p>Shop 59, Everyday Supermarket Plaza, Choba, UNIPORT, Port Harcourt</p><p><b>Phone:</b> 0806 023 2119</p><div class="modal-actions"><a class="primary" style="text-align:center;text-decoration:none;padding:12px;border-radius:12px" href="tel:+2348060232119">Call store</a><button class="secondary" onclick="closeModal()">Close</button></div>');

document.querySelectorAll(".nav-item").forEach(btn=>btn.onclick=()=>{
 document.querySelectorAll(".nav-item").forEach(x=>x.classList.remove("active"));btn.classList.add("active");
 document.querySelectorAll("main.page").forEach(x=>x.classList.add("hidden"));$(btn.dataset.view).classList.remove("hidden");window.scrollTo({top:0,behavior:"smooth"});
});
renderCategories();renderProducts();