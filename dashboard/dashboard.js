const SUPABASE_URL = 'https://alczyftlhcdsifjntcbh.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsY3p5ZnRsaGNkc2lmam50Y2JoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY5NzE1MTAsImV4cCI6MjA4MjU0NzUxMH0.839c_boZy57LB-gBXuJjevubC2VVYmvNkQdTg1uB-y0';

const client = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

let nodeEarnings = {}; // { node_id: total_pulses }
let referralMap = {};  // { invitee_id: inviter_id }
let inviterMap = {};   // { inviter_id: [child_id1, child_id2...] }

let isInitialized = false;

async function init() {
    console.log("🚀 Dashboard Ignited v2.3 - Real Bonus System");
    await updateStats();
    await fetchReferrals(); // 获取族谱
    await fetchLeaderboard(true);
    subscribeToReadings();
    subscribeToNodes(); // 监听新的邀请关系
    isInitialized = true;
}

async function updateStats() {
    const { count: readingsCount } = await client.from('readings').select('*', { count: 'exact', head: true });
    if (readingsCount !== null) document.getElementById('total-readings').innerText = readingsCount.toLocaleString();

    const { data: nodes } = await client.from('nodes').select('id');
    if (nodes) document.getElementById('total-sentinels').innerText = nodes.length;
}

// 1. 获取邀请族谱
async function fetchReferrals() {
    const { data, error } = await client.from('nodes').select('id, referred_by');
    if (error) {
        console.error("Referral fetch error:", error);
        return;
    }

    referralMap = {};
    inviterMap = {};

    data.forEach(node => {
        if (node.referred_by) {
            referralMap[node.id] = node.referred_by;

            if (!inviterMap[node.referred_by]) {
                inviterMap[node.referred_by] = [];
            }
            inviterMap[node.referred_by].push(node.id);
        }
    });
    console.log("Referral Map Updated:", inviterMap);
}

// 2. 获取基础产量
async function fetchLeaderboard(reset = false) {
    const { data: earningsData, error } = await client.from('readings').select('node_id');
    if (error) return;

    if (reset) nodeEarnings = {};

    const counts = {};
    earningsData.forEach(r => {
        counts[r.node_id] = (counts[r.node_id] || 0) + 1;
    });

    if (reset) {
        nodeEarnings = counts;
    } else {
        Object.keys(counts).forEach(id => {
            if (!nodeEarnings[id]) nodeEarnings[id] = counts[id];
        });
    }

    renderLeaderboard();
}

// 3. 核心算法：计算收益（含Bonus）
function calculateTotalCredits(nodeId, pulses) {
    const baseEarning = pulses * 0.001;

    // 计算下线贡献的Bonus (每个下线产出的 10%)
    let bonus = 0;
    if (inviterMap[nodeId]) {
        inviterMap[nodeId].forEach(childId => {
            const childPulses = nodeEarnings[childId] || 0;
            const childBaseEarning = childPulses * 0.001;
            bonus += childBaseEarning * 0.10; // 10% 分成
        });
    }

    return {
        total: (baseEarning + bonus).toFixed(4),
        base: baseEarning.toFixed(4),
        bonus: bonus.toFixed(4),
        rawBonus: bonus
    };
}

// 4. 渲染榜单
function renderLeaderboard() {
    const leaderboardEl = document.getElementById('leaderboard');
    leaderboardEl.innerHTML = '';

    // 预计算所有数据以便排序
    const sortedNodes = Object.keys(nodeEarnings).map(id => {
        const pulses = nodeEarnings[id];
        const stats = calculateTotalCredits(id, pulses);
        return {
            id,
            pulses,
            ...stats
        };
    }).sort((a, b) => parseFloat(b.total) - parseFloat(a.total));

    sortedNodes.forEach((node, index) => {
        const item = document.createElement('div');
        item.className = 'leaderboard-item';

        // 检查这个节点是不是别人的Inviter (是否有下线)
        const isInviter = inviterMap[node.id] && inviterMap[node.id].length > 0;
        const hasBonus = node.rawBonus > 0;

        item.innerHTML = `
            <div class="sentinel-info">
                <div class="avatar">${index + 1}</div>
                <div>
                    <div class="node-name">Sentinel ${node.id.slice(0, 6)}</div>
                    <div class="node-id">
                        ${node.id} 
                        ${isInviter ? '<span class="tag">INVITER</span>' : ''}
                    </div>
                </div>
            </div>
            <div class="earnings">
                <div class="amount" id="earn-${node.id}" style="${hasBonus ? 'color: #3b82f6;' : ''}">
                    ${node.total} CREDITS
                </div>
                <div class="node-id" id="pulse-${node.id}">
                    ${node.pulses} Pulses 
                    ${hasBonus ? `<span style="color:#10b981; font-weight:bold;">(+${node.bonus} BONUS)</span>` : ''}
                </div>
            </div>
        `;
        leaderboardEl.appendChild(item);
    });
}

// 5. 实时数据流监听
function subscribeToReadings() {
    client.channel('realtime-refinery-readings')
        .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'readings' }, (payload) => {
            const node = payload.new.node_id;

            // 更新日志
            const logEl = document.getElementById('live-log');
            const line = document.createElement('div');
            line.className = 'log-line incoming';
            line.innerHTML = `<span class="timestamp">[${new Date().toLocaleTimeString()}]</span> <span class="accent">DATA INGRESS</span> from <span class="highlight">${node.slice(0, 8)}</span>`;
            logEl.prepend(line);
            if (logEl.children.length > 50) logEl.lastChild.remove();

            // 更新总数
            const totalReadingsEl = document.getElementById('total-readings');
            totalReadingsEl.innerText = (parseInt(totalReadingsEl.innerText.replace(/,/g, '')) + 1).toLocaleString();

            // 更新内存计数
            if (nodeEarnings[node] !== undefined) {
                nodeEarnings[node]++;
            } else {
                console.log(`🆕 New node detected: ${node}`);
                nodeEarnings[node] = 1;
            }

            // 每次数据更新都重新渲染，确保Bonus实时联动
            // (例如 B 的数据更新了，A 的 Bonus 也要立即增加)
            renderLeaderboard();
        })
        .subscribe();
}

// 6. 实时关系网监听
function subscribeToNodes() {
    client.channel('realtime-refinery-nodes')
        .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'nodes' }, async (payload) => {
            console.log("🔗 Referral relationship updated!", payload);
            await fetchReferrals();
            renderLeaderboard();
        })
        .subscribe();
}

window.onload = init;
