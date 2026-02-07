### Aktuelle Themen:
* [Taylor-Polynome](taylor_polynome.html)
* [Weitere Themen folgen bald...](#)

---
*Erstellt mit Julia und Pluto.jl*

<div style="background: #fdfdfd; padding: 25px; border: 1px solid #eee; border-radius: 15px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
    <p style="font-family: sans-serif; font-size: 1.1em;">
        Aktueller Grad: <strong id="n-display" style="color: #D95319; font-size: 1.4em;">1</strong>
    </p>
    
    <input type="range" id="taylor-slider" min="1" max="25" step="2" value="1" 
           style="width: 100%; max-width: 400px; margin: 10px 0; cursor: pointer;">

    <div style="margin-top: 20px;">
        <img id="taylor-img" src="outputs/sin_taylor_n1.png" 
             style="width: 100%; max-width: 700px; height: auto; border-radius: 8px;">
    </div>
</div>

<script>
    const slider = document.getElementById('taylor-slider');
    const display = document.getElementById('n-display');
    const img = document.getElementById('taylor-img');

    slider.addEventListener('input', function() {
        const n = this.value;
        display.innerText = n;
        // Der Pfad ist relativ zur index.html
        img.src = `outputs/sin_taylor_n${n}.png`;
    });
</script>
