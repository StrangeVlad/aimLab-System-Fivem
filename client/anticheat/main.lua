-- Encrypt (Anticheat)

function Encrypt(x)
    if Config.Aimlab_Anticheat then
        x = x * 62 + 2 * 81999 % 99999;
    end
    return math.floor(x)
end