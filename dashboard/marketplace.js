// Marketplace Logic
const SUPABASE_URL = 'https://alczyftlhcdsifjntcbh.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsY3p5ZnRsaGNkc2lmam50Y2JoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY5NzE1MTAsImV4cCI6MjA4MjU0NzUxMH0.839c_boZy57LB-gBXuJjevubC2VVYmvNkQdTg1uB-y0';

const client = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// Leaflet Map Instance
let map;

async function initMarketplace() {
    console.log("🏪 Marketplace Initializing v3.0 (Light Mode + Search)...");

    // 1. 初始化地图
    map = L.map('map-container', {
        zoomControl: false // 我们稍后把 zoom 放到右下角，左上角给搜索框
    }).setView([39.9, 116.4], 3);

    L.control.zoom({ position: 'bottomright' }).addTo(map);

    // 2. 切换到亮色地图 (CartoDB Voyager - 非常现代且清晰)
    L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
        subdomains: 'abcd',
        maxZoom: 19
    }).addTo(map);

    // 3. 添加搜索控件
    addSearchControl();

    // 4. 加载数据
    await loadMapData();
    await loadMarketStats();
}

function addSearchControl() {
    const SearchControl = L.Control.extend({
        onAdd: function () {
            const div = L.DomUtil.create('div', 'map-search-control');
            div.innerHTML = `
                <input type="text" id="city-search" placeholder="Search city or area..." />
                <button onclick="searchCity()">Go</button>
            `;
            // 防止地图点击穿透
            L.DomEvent.disableClickPropagation(div);
            return div;
        },
        onRemove: function () { }
    });

    // 放到左上角
    new SearchControl({ position: 'topleft' }).addTo(map);

    // 绑定回车键
    setTimeout(() => {
        document.getElementById('city-search').addEventListener('keypress', function (e) {
            if (e.key === 'Enter') searchCity();
        });
    }, 500);
}

// 供全局调用
window.searchCity = async function () {
    const query = document.getElementById('city-search').value;
    if (!query) return;

    const btn = document.querySelector('.map-search-control button');
    const originalText = btn.innerText;
    btn.innerText = '...';

    try {
        // 使用 Nominatim (OpenStreetMap) 免费 Geocoding API
        const response = await fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}`);
        const data = await response.json();

        if (data && data.length > 0) {
            const place = data[0];
            const lat = parseFloat(place.lat);
            const lon = parseFloat(place.lon);
            const bbox = place.boundingbox; // [minLat, maxLat, minLon, maxLon]

            // 飞到该地点
            if (bbox) {
                map.fitBounds([
                    [bbox[0], bbox[2]],
                    [bbox[1], bbox[3]]
                ]);
            } else {
                map.setView([lat, lon], 12);
            }

            console.log(`🗺️ Flew to ${place.display_name}`);
        } else {
            alert("City not found!");
        }
    } catch (e) {
        console.error("Geocoding failed", e);
        alert("Search failed. Please try again.");
    } finally {
        btn.innerText = originalText;
    }
};

async function loadMapData() {
    // 获取最近的 500 个数据点
    const { data, error } = await client
        .from('readings')
        .select('location, pressure_hpa, decibel_db, node_id, timestamp')
        .order('timestamp', { ascending: false })
        .limit(1000); // 增加限制以获得更好的密度

    if (error) {
        console.error("Map data load failed:", error);
        return;
    }

    const markers = L.layerGroup().addTo(map);
    const hexLayer = L.layerGroup().addTo(map);
    let validBounds = [];

    // H3 Aggregation Logic
    const hexMap = new Map(); // h3Index -> { count: 0, nodeIds: Set(), totalNoise: 0 }
    const res = 9; // H3 Resolution

    data.forEach(point => {
        if (!point.location) return;

        try {
            // WKB Parser (Hex -> Double)
            let lat, lng;
            if (typeof point.location === 'string' && point.location.length > 20 && /^[0-9A-Fa-f]+$/.test(point.location)) {
                const hexLng = point.location.substring(18, 34);
                const hexLat = point.location.substring(34, 50);
                lng = parseHexString(hexLng);
                lat = parseHexString(hexLat);
            } else {
                return;
            }

            if (isNaN(lat) || isNaN(lng)) return;

            // Compute H3 Index
            const h3Index = h3.latLngToCell(lat, lng, res);

            // Update Aggregation
            if (!hexMap.has(h3Index)) {
                hexMap.set(h3Index, {
                    count: 0,
                    nodeIds: new Set(),
                    totalNoise: 0,
                    lat: lat, // Keep one ref point for centering if needed
                    lng: lng
                });
            }
            const cell = hexMap.get(h3Index);
            cell.count++;
            cell.nodeIds.add(point.node_id);
            cell.totalNoise += point.decibel_db;

            // Keep individual markers for recent "live" points only (optional, clutter reduction)
            const now = new Date();
            const dataTime = new Date(point.timestamp);
            const diffMins = (now - dataTime) / 1000 / 60;
            const isLive = diffMins < 10;

            if (isLive) {
                const isNoisy = point.decibel_db > 50;
                const markerColor = isNoisy ? '#ef4444' : '#3b82f6';

                const icon = L.divIcon({
                    className: 'custom-pin',
                    html: `
                        <svg viewBox="0 0 24 24" width="36" height="36" fill="${markerColor}" stroke="white" stroke-width="1.5">
                            <path d="M12 0C7.58 0 4 3.58 4 8c0 5.25 7 13 7 13s7-7.75 7-13c0-4.42-3.58-8-8-8zm0 11c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3-3 3z"/>
                        </svg>
                        ${isLive ? '<div class="pulse-ring"></div>' : ''}
                    `,
                    iconSize: [36, 36],
                    iconAnchor: [18, 36],
                    popupAnchor: [0, -36]
                });

                L.marker([lat, lng], { icon: icon })
                    .bindPopup(`
                        <div style="font-family: sans-serif; color: #333; min-width: 150px;">
                            <h4 style="margin:0 0 5px 0; color: #10b981;">Sentinel Node</h4>
                            <div style="font-size: 12px; color: #666;">ID: ${point.node_id.slice(0, 8)}...</div>
                            <hr style="border:0; border-top:1px solid #eee; margin:5px 0;">
                            <div><b>Pressure:</b> ${point.pressure_hpa.toFixed(1)} hPa</div>
                            <div><b>Noise:</b> ${point.decibel_db.toFixed(1)} dB</div>
                            <div style="margin-top:5px; font-size:11px; color:#999;">${new Date(point.timestamp).toLocaleTimeString()}</div>
                        </div>
                    `)
                    .addTo(markers);
            }

            validBounds.push([lat, lng]);
        } catch (e) {
            console.warn("Parse error for point:", e);
        }
    });

    // Draw Hexagons
    hexMap.forEach((data, h3Index) => {
        const boundary = h3.cellToBoundary(h3Index);
        const uniqueNodes = data.nodeIds.size;

        // Multiplier Logic
        let multiplier = 1.0;
        let color = '#3b82f6'; // Default Blue
        let opacity = 0.2;

        if (uniqueNodes === 1) {
            multiplier = 2.0;
            color = '#10b981'; // Green (Discovery Bonus)
            opacity = 0.4;
        } else if (uniqueNodes > 5) {
            multiplier = 0.5;
            color = '#ef4444'; // Red (Saturation)
            opacity = 0.5;
        } else {
            color = '#f59e0b'; // Amber (Normal)
            opacity = 0.3;
        }

        const polygon = L.polygon(boundary, {
            color: color,
            weight: 1,
            fillOpacity: opacity
        }).addTo(hexLayer);

        polygon.bindPopup(`
            <div style="font-family: sans-serif; color: #333;">
                <h4 style="margin:0 0 5px 0; color: ${color};">Hex Zone</h4>
                <div style="font-size:10px; color:#999; margin-bottom:5px;">ID: ${h3Index}</div>
                <div style="display:flex; justify-content:space-between; margin-bottom:5px;">
                    <span>Nodes:</span> <b>${uniqueNodes}</b>
                </div>
                <div style="display:flex; justify-content:space-between; margin-bottom:5px;">
                    <span>Reward:</span> <b style="color:${color}">${multiplier}x</b>
                </div>
                <div style="font-size:11px; color:#666; margin-top:5px;">
                    Avg Noise: ${(data.totalNoise / data.count).toFixed(1)} dB
                </div>
            </div>
        `);
    });

    if (validBounds.length > 0) {
        map.fitBounds(validBounds, { padding: [50, 50] });
    }
}

// 辅助函数：解析 IEEE 754 Double (Little Endian)
function parseHexString(hex) {
    if (!hex) return 0;
    const buffer = new ArrayBuffer(8);
    const view = new DataView(buffer);
    for (let i = 0; i < 16; i += 2) {
        const byteValue = parseInt(hex.substr(i, 2), 16);
        view.setUint8(i / 2, byteValue);
    }
    return view.getFloat64(0, true);
}

async function loadMarketStats() {
    const { count } = await client.from('readings').select('*', { count: 'exact', head: true });
    if (count) {
        document.getElementById('market-total-points').innerText = count.toLocaleString();
        const value = count * 0.0005;
        document.getElementById('market-value').innerText = '$' + value.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        document.getElementById('active-nodes-count').innerText = 2; // Mock active count for now
    }
}

window.onload = initMarketplace;
