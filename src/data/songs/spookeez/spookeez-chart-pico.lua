return {
    version = "2.0.0",
    scrollSpeed = {
        easy = 2.3,
        normal = 2.4,
        hard = 2.6,
    },
    events = {
        {
            t = 0,
            e = "FocusCamera",
            v = {
                x = 0,
                duration = 4,
                y = 0,
                char = 0,
                ease = "CLASSIC",
            },
        },
        {
            t = 100,
            e = "SetCameraBop",
            v = {
                rate = 2,
                intensity = 0.8,
            },
        },
        {
            t = 6000,
            e = "PlayAnimation",
            v = {
                target = "bf",
                force = true,
                anim = "hey",
            },
        },
        {
            t = 6300,
            e = "SetCameraBop",
            v = {
                rate = 2,
                intensity = 1,
            },
        },
        {
            t = 6400,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 9600,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 0,
            },
        },
        {
            t = 12800,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 15600,
            e = "PlayAnimation",
            v = {
                anim = "cheer",
                force = true,
                target = "dad",
            },
        },
        {
            t = 16000,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 0,
            },
        },
        {
            t = 17800,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.1,
            },
        },
        {
            t = 18800,
            e = "PlayAnimation",
            v = {
                target = "boyfriend",
                anim = "cheer",
                force = true,
            },
        },
        {
            t = 18800,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 19200,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 25600,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 0,
            },
        },
        {
            t = 28000,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.05,
            },
        },
        {
            t = 28300,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.1,
            },
        },
        {
            t = 28800,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.15,
            },
        },
        {
            t = 31000,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.1,
            },
        },
        {
            t = 31200,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.05,
            },
        },
        {
            t = 32000,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 32050,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 35200,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 0,
            },
        },
        {
            t = 38400,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 41200,
            e = "PlayAnimation",
            v = {
                anim = "cheer",
                force = true,
                target = "dad",
            },
        },
        {
            t = 41600,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 0,
            },
        },
        {
            t = 43400,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1.1,
                mode = "stage",
            },
        },
        {
            t = 44400,
            e = "PlayAnimation",
            v = {
                force = true,
                anim = "cheer",
                target = "boyfriend",
            },
        },
        {
            t = 44400,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 44800,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 48200,
            e = "FocusCamera",
            v = {
                x = 300,
                duration = 4,
                y = 0,
                char = 1,
                ease = "CLASSIC",
            },
        },
        {
            t = 48250,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 0.9,
                mode = "stage",
            },
        },
        {
            t = 51200,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 0,
            },
        },
        {
            t = 51250,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 53600,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1.05,
                mode = "stage",
            },
        },
        {
            t = 53900,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1.1,
                mode = "stage",
            },
        },
        {
            t = 54400,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1.15,
                mode = "stage",
            },
        },
        {
            t = 56800,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.1,
            },
        },
        {
            t = 57200,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.05,
            },
        },
        {
            t = 57500,
            e = "SetCameraBop",
            v = {
                rate = 1,
                intensity = 1.1,
            },
        },
        {
            t = 57600,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 57650,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1,
                mode = "stage",
            },
        },
        {
            t = 62400,
            e = "FocusCamera",
            v = {
                x = 300,
                duration = 4,
                y = 0,
                char = 1,
                ease = "CLASSIC",
            },
        },
        {
            t = 62450,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 0.9,
                mode = "stage",
            },
        },
        {
            t = 64000,
            e = "FocusCamera",
            v = {
                x = 0,
                duration = 4,
                y = 0,
                char = 0,
                ease = "CLASSIC",
            },
        },
        {
            t = 64050,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1,
                mode = "stage",
            },
        },
        {
            t = 64800,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.04,
            },
        },
        {
            t = 65200,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.08,
            },
        },
        {
            t = 66400,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.12,
            },
        },
        {
            t = 66800,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.16,
            },
        },
        {
            t = 68000,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.2,
            },
        },
        {
            t = 68400,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.24,
            },
        },
        {
            t = 69800,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.2,
            },
        },
        {
            t = 70000,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.1,
            },
        },
        {
            t = 70400,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 70450,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 75200,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 300,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 75250,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 0.9,
            },
        },
        {
            t = 76800,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 0,
            },
        },
        {
            t = 76850,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 78400,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.04,
            },
        },
        {
            t = 80000,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.08,
            },
        },
        {
            t = 80800,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.12,
            },
        },
        {
            t = 81200,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.16,
            },
        },
        {
            t = 81600,
            e = "FocusCamera",
            v = {
                x = 300,
                duration = 4,
                y = 0,
                char = 1,
                ease = "CLASSIC",
            },
        },
        {
            t = 81650,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 0.9,
                mode = "stage",
            },
        },
        {
            t = 83100,
            e = "SetCameraBop",
            v = {
                rate = 4,
                intensity = 0,
            },
        },
        {
            t = 83200,
            e = "FocusCamera",
            v = {
                duration = 4,
                x = 0,
                y = 0,
                ease = "CLASSIC",
                char = 1,
            },
        },
        {
            t = 83250,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1,
            },
        },
        {
            t = 88000,
            e = "FocusCamera",
            v = {
                x = 300,
                duration = 4,
                y = 0,
                char = 1,
                ease = "CLASSIC",
            },
        },
        {
            t = 88050,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 0.9,
                mode = "stage",
            },
        },
        {
            t = 89600,
            e = "FocusCamera",
            v = {
                x = 0,
                duration = 4,
                y = 0,
                char = 0,
                ease = "CLASSIC",
            },
        },
        {
            t = 89650,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1,
                mode = "stage",
            },
        },
        {
            t = 91200,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1.04,
                mode = "stage",
            },
        },
        {
            t = 92800,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1.08,
                mode = "stage",
            },
        },
        {
            t = 93600,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1.12,
                mode = "stage",
            },
        },
        {
            t = 94000,
            e = "ZoomCamera",
            v = {
                ease = "expoOut",
                duration = 16,
                zoom = 1.16,
                mode = "stage",
            },
        },
        {
            t = 94400,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.12,
            },
        },
        {
            t = 95200,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.08,
            },
        },
        {
            t = 95600,
            e = "ZoomCamera",
            v = {
                duration = 16,
                ease = "expoOut",
                mode = "stage",
                zoom = 1.04,
            },
        },
    },
    notes = {
        easy = {
            {
                t = 1200,
                d = 3,
                l = 125,
            },
            {
                t = 2800,
                d = 2,
                l = 100,
            },
            {
                t = 4200,
                d = 1,
            },
            {
                t = 4400,
                d = 0,
            },
            {
                t = 4600,
                d = 1,
            },
            {
                t = 4800,
                d = 3,
            },
            {
                t = 6400,
                d = 4,
            },
            {
                t = 6599,
                d = 5,
            },
            {
                t = 6799,
                d = 7,
            },
            {
                t = 7199,
                d = 7,
            },
            {
                t = 7599,
                d = 6,
            },
            {
                t = 7799,
                d = 7,
            },
            {
                t = 7999,
                d = 5,
            },
            {
                t = 8200,
                d = 7,
            },
            {
                t = 8400,
                d = 7,
            },
            {
                t = 8800,
                d = 6,
            },
            {
                t = 9200,
                d = 4,
            },
            {
                t = 9400,
                d = 7,
            },
            {
                t = 9600,
                d = 3,
                l = 100,
            },
            {
                t = 10000,
                d = 1,
            },
            {
                t = 10400,
                d = 3,
            },
            {
                t = 10800,
                d = 2,
            },
            {
                t = 11200,
                d = 3,
                l = 125,
            },
            {
                t = 11600,
                d = 1,
            },
            {
                t = 11800,
                d = 0,
            },
            {
                t = 12000,
                d = 3,
            },
            {
                t = 12400,
                d = 2,
            },
            {
                t = 12600,
                d = 2,
                l = 125,
            },
            {
                t = 12800,
                d = 6,
            },
            {
                t = 12999,
                d = 7,
            },
            {
                t = 13099,
                d = 5,
            },
            {
                t = 13199,
                d = 4,
            },
            {
                t = 13399,
                d = 4,
            },
            {
                t = 13599,
                d = 6,
            },
            {
                t = 13799,
                d = 7,
            },
            {
                t = 13999,
                d = 5,
            },
            {
                t = 14399,
                d = 5,
            },
            {
                t = 14599,
                d = 4,
            },
            {
                t = 14699,
                d = 5,
            },
            {
                t = 14799,
                d = 7,
            },
            {
                t = 14999,
                d = 7,
            },
            {
                t = 15199,
                d = 4,
            },
            {
                t = 15200,
                d = 3,
            },
            {
                t = 15399,
                d = 4,
            },
            {
                t = 15600,
                d = 6,
                k = "cheer",
            },
            {
                t = 15600,
                d = 0,
            },
            {
                t = 16000,
                d = 2,
            },
            {
                t = 16400,
                d = 0,
            },
            {
                t = 16600,
                d = 0,
                l = 100,
            },
            {
                t = 16800,
                d = 3,
            },
            {
                t = 17200,
                d = 2,
                l = 200,
            },
            {
                t = 17800,
                d = 3,
                l = 100,
            },
            {
                t = 18000,
                d = 2,
                l = 100,
            },
            {
                t = 18400,
                d = 3,
                l = 175,
            },
            {
                t = 18800,
                d = 4,
                k = "cheer",
            },
            {
                t = 19000,
                d = 7,
            },
            {
                t = 19200,
                d = 6,
            },
            {
                t = 19400,
                d = 7,
            },
            {
                t = 19500,
                d = 5,
            },
            {
                t = 19600,
                d = 7,
            },
            {
                t = 20000,
                d = 7,
            },
            {
                t = 20300,
                d = 7,
            },
            {
                t = 20600,
                d = 7,
            },
            {
                t = 20800,
                d = 6,
            },
            {
                t = 21000,
                d = 4,
            },
            {
                t = 21100,
                d = 5,
            },
            {
                t = 21200,
                d = 7,
            },
            {
                t = 21600,
                d = 7,
            },
            {
                t = 21900,
                d = 5,
            },
            {
                t = 22000,
                d = 7,
            },
            {
                t = 22200,
                d = 7,
            },
            {
                t = 22400,
                d = 6,
            },
            {
                t = 22600,
                d = 7,
            },
            {
                t = 22700,
                d = 5,
            },
            {
                t = 22800,
                d = 7,
            },
            {
                t = 23200,
                d = 7,
            },
            {
                t = 23500,
                d = 7,
            },
            {
                t = 23800,
                d = 7,
            },
            {
                t = 24000,
                d = 6,
            },
            {
                t = 24200,
                d = 4,
            },
            {
                t = 24300,
                d = 5,
            },
            {
                t = 24400,
                d = 7,
            },
            {
                t = 24800,
                d = 5,
            },
            {
                t = 25200,
                d = 6,
            },
            {
                t = 25400,
                d = 6,
            },
            {
                t = 25400,
                d = 3,
            },
            {
                t = 25600,
                d = 0,
            },
            {
                t = 25800,
                d = 2,
            },
            {
                t = 26000,
                d = 0,
            },
            {
                t = 26200,
                d = 3,
            },
            {
                t = 26400,
                d = 1,
            },
            {
                t = 26700,
                d = 1,
            },
            {
                t = 27000,
                d = 0,
            },
            {
                t = 27200,
                d = 3,
            },
            {
                t = 27400,
                d = 2,
            },
            {
                t = 27600,
                d = 1,
            },
            {
                t = 27800,
                d = 3,
            },
            {
                t = 28000,
                d = 1,
            },
            {
                t = 28400,
                d = 1,
            },
            {
                t = 28800,
                d = 1,
            },
            {
                t = 29200,
                d = 3,
            },
            {
                t = 29400,
                d = 1,
                l = 100,
            },
            {
                t = 29800,
                d = 3,
            },
            {
                t = 30000,
                d = 1,
                l = 125,
            },
            {
                t = 30400,
                d = 1,
                l = 125,
            },
            {
                t = 30600,
                d = 0,
                l = 75,
            },
            {
                t = 31000,
                d = 2,
            },
            {
                t = 31200,
                d = 2,
            },
            {
                t = 31599,
                d = 7,
            },
            {
                t = 31799,
                d = 5,
            },
            {
                t = 31999,
                d = 4,
            },
            {
                t = 32199,
                d = 5,
            },
            {
                t = 32399,
                d = 7,
            },
            {
                t = 32800,
                d = 7,
            },
            {
                t = 33200,
                d = 6,
            },
            {
                t = 33400,
                d = 7,
            },
            {
                t = 33600,
                d = 5,
            },
            {
                t = 33800,
                d = 7,
            },
            {
                t = 34000,
                d = 7,
            },
            {
                t = 34400,
                d = 6,
            },
            {
                t = 34800,
                d = 4,
            },
            {
                t = 35000,
                d = 7,
            },
            {
                t = 35200,
                d = 3,
                l = 100,
            },
            {
                t = 35600,
                d = 1,
            },
            {
                t = 36000,
                d = 3,
            },
            {
                t = 36400,
                d = 2,
            },
            {
                t = 36600,
                d = 0,
            },
            {
                t = 36800,
                d = 3,
                l = 125,
            },
            {
                t = 37200,
                d = 1,
            },
            {
                t = 37600,
                d = 3,
            },
            {
                t = 38000,
                d = 3,
            },
            {
                t = 38200,
                d = 0,
                l = 125,
            },
            {
                t = 38400,
                d = 6,
            },
            {
                t = 38600,
                d = 7,
            },
            {
                t = 38700,
                d = 5,
            },
            {
                t = 38800,
                d = 4,
            },
            {
                t = 39000,
                d = 4,
            },
            {
                t = 39200,
                d = 6,
            },
            {
                t = 39400,
                d = 7,
            },
            {
                t = 39600,
                d = 5,
            },
            {
                t = 40000,
                d = 5,
            },
            {
                t = 40200,
                d = 4,
            },
            {
                t = 40300,
                d = 5,
            },
            {
                t = 40400,
                d = 7,
            },
            {
                t = 40600,
                d = 7,
            },
            {
                t = 40800,
                d = 4,
            },
            {
                t = 40800,
                d = 3,
            },
            {
                t = 41000,
                d = 4,
            },
            {
                t = 41000,
                d = 3,
            },
            {
                t = 41200,
                d = 6,
            },
            {
                t = 41200,
                d = 0,
            },
            {
                t = 41400,
                d = 2,
            },
            {
                t = 41600,
                d = 3,
            },
            {
                t = 42000,
                d = 0,
            },
            {
                t = 42400,
                d = 3,
            },
            {
                t = 42600,
                d = 0,
            },
            {
                t = 42800,
                d = 2,
                l = 200,
            },
            {
                t = 43400,
                d = 3,
            },
            {
                t = 43600,
                d = 2,
                l = 100,
            },
            {
                t = 44000,
                d = 0,
            },
            {
                t = 44200,
                d = 2,
            },
            {
                t = 44400,
                d = 4,
            },
            {
                t = 44600,
                d = 7,
            },
            {
                t = 44800,
                d = 6,
            },
            {
                t = 45000,
                d = 7,
            },
            {
                t = 45100,
                d = 5,
            },
            {
                t = 45200,
                d = 7,
            },
            {
                t = 45500,
                d = 7,
            },
            {
                t = 45600,
                d = 7,
            },
            {
                t = 45900,
                d = 7,
            },
            {
                t = 46200,
                d = 7,
            },
            {
                t = 46400,
                d = 6,
            },
            {
                t = 46600,
                d = 4,
            },
            {
                t = 46700,
                d = 5,
            },
            {
                t = 46800,
                d = 7,
            },
            {
                t = 47100,
                d = 7,
            },
            {
                t = 47200,
                d = 5,
            },
            {
                t = 47400,
                d = 4,
            },
            {
                t = 47500,
                d = 6,
            },
            {
                t = 47600,
                d = 7,
            },
            {
                t = 47800,
                d = 7,
            },
            {
                t = 47900,
                d = 5,
            },
            {
                t = 48000,
                d = 6,
            },
            {
                t = 48200,
                d = 7,
            },
            {
                t = 48200,
                d = 3,
            },
            {
                t = 48300,
                d = 5,
            },
            {
                t = 48400,
                d = 7,
            },
            {
                t = 48400,
                d = 1,
            },
            {
                t = 48600,
                d = 0,
            },
            {
                t = 48800,
                d = 7,
            },
            {
                t = 48800,
                d = 3,
            },
            {
                t = 49000,
                d = 0,
            },
            {
                t = 49100,
                d = 7,
            },
            {
                t = 49200,
                d = 2,
                l = 175,
            },
            {
                t = 49400,
                d = 7,
            },
            {
                t = 49600,
                d = 6,
            },
            {
                t = 49800,
                d = 4,
            },
            {
                t = 49800,
                d = 3,
            },
            {
                t = 49900,
                d = 5,
            },
            {
                t = 50000,
                d = 7,
            },
            {
                t = 50000,
                d = 1,
            },
            {
                t = 50200,
                d = 3,
            },
            {
                t = 50400,
                d = 7,
            },
            {
                t = 50400,
                d = 3,
                l = 200,
            },
            {
                t = 50700,
                d = 7,
            },
            {
                t = 50800,
                d = 0,
                l = 200,
            },
            {
                t = 51000,
                d = 7,
            },
            {
                t = 51200,
                d = 3,
            },
            {
                t = 51400,
                d = 0,
            },
            {
                t = 51600,
                d = 3,
            },
            {
                t = 51800,
                d = 3,
            },
            {
                t = 52000,
                d = 1,
            },
            {
                t = 52300,
                d = 1,
            },
            {
                t = 52600,
                d = 0,
            },
            {
                t = 52800,
                d = 3,
            },
            {
                t = 53000,
                d = 2,
            },
            {
                t = 53200,
                d = 1,
            },
            {
                t = 53400,
                d = 3,
            },
            {
                t = 53600,
                d = 0,
            },
            {
                t = 54000,
                d = 1,
            },
            {
                t = 54400,
                d = 1,
            },
            {
                t = 54800,
                d = 3,
            },
            {
                t = 55000,
                d = 1,
                l = 116.666666666663,
            },
            {
                t = 55400,
                d = 3,
            },
            {
                t = 55600,
                d = 1,
                l = 125,
            },
            {
                t = 56000,
                d = 1,
                l = 125,
            },
            {
                t = 56200,
                d = 0,
                l = 75,
            },
            {
                t = 56600,
                d = 2,
            },
            {
                t = 56800,
                d = 2,
            },
            {
                t = 57200,
                d = 0,
                l = 216.666666666663,
            },
            {
                t = 57550,
                d = 4,
            },
            {
                t = 57600,
                d = 6,
                l = 300,
            },
            {
                t = 58000,
                d = 7,
                l = 300,
            },
            {
                t = 58400,
                d = 5,
                l = 150,
            },
            {
                t = 58650,
                d = 7,
            },
            {
                t = 58700,
                d = 4,
            },
            {
                t = 58800,
                d = 6,
                l = 300,
            },
            {
                t = 59200,
                d = 6,
                l = 100,
            },
            {
                t = 59400,
                d = 7,
                l = 100,
            },
            {
                t = 59600,
                d = 4,
                l = 200,
            },
            {
                t = 59850,
                d = 6,
            },
            {
                t = 59900,
                d = 4,
            },
            {
                t = 60000,
                d = 5,
                l = 300,
            },
            {
                t = 60400,
                d = 6,
                l = 300,
            },
            {
                t = 60800,
                d = 5,
            },
            {
                t = 61200,
                d = 5,
            },
            {
                t = 61400,
                d = 7,
            },
            {
                t = 61800,
                d = 7,
            },
            {
                t = 62000,
                d = 4,
            },
            {
                t = 62100,
                d = 3,
                l = 125,
            },
            {
                t = 62200,
                d = 7,
            },
            {
                t = 62350,
                d = 1,
                l = 125,
            },
            {
                t = 62400,
                d = 5,
            },
            {
                t = 62800,
                d = 5,
            },
            {
                t = 62800,
                d = 3,
            },
            {
                t = 63000,
                d = 7,
            },
            {
                t = 63000,
                d = 0,
                l = 125,
            },
            {
                t = 63400,
                d = 7,
            },
            {
                t = 63400,
                d = 3,
                l = 125,
            },
            {
                t = 63500,
                d = 7,
            },
            {
                t = 63600,
                d = 4,
            },
            {
                t = 63600,
                d = 0,
            },
            {
                t = 63800,
                d = 7,
            },
            {
                t = 63800,
                d = 0,
            },
            {
                t = 64000,
                d = 2,
            },
            {
                t = 64200,
                d = 3,
                l = 100,
            },
            {
                t = 64600,
                d = 0,
            },
            {
                t = 64800,
                d = 1,
            },
            {
                t = 65200,
                d = 3,
                l = 150,
            },
            {
                t = 65600,
                d = 3,
            },
            {
                t = 65800,
                d = 1,
            },
            {
                t = 66200,
                d = 3,
            },
            {
                t = 66400,
                d = 0,
            },
            {
                t = 66800,
                d = 1,
                l = 100,
            },
            {
                t = 67200,
                d = 0,
            },
            {
                t = 67400,
                d = 2,
            },
            {
                t = 67800,
                d = 1,
            },
            {
                t = 68000,
                d = 3,
            },
            {
                t = 68400,
                d = 0,
                l = 200,
            },
            {
                t = 68800,
                d = 3,
            },
            {
                t = 69000,
                d = 2,
            },
            {
                t = 69400,
                d = 3,
            },
            {
                t = 69600,
                d = 0,
            },
            {
                t = 69800,
                d = 2,
            },
            {
                t = 70000,
                d = 0,
                l = 125,
            },
            {
                t = 70400,
                d = 6,
            },
            {
                t = 70600,
                d = 6,
            },
            {
                t = 70800,
                d = 7,
            },
            {
                t = 71000,
                d = 6,
            },
            {
                t = 71400,
                d = 7,
            },
            {
                t = 71600,
                d = 5,
            },
            {
                t = 71800,
                d = 7,
            },
            {
                t = 72000,
                d = 6,
            },
            {
                t = 72200,
                d = 6,
            },
            {
                t = 72400,
                d = 7,
            },
            {
                t = 72600,
                d = 6,
            },
            {
                t = 73000,
                d = 7,
            },
            {
                t = 73200,
                d = 5,
            },
            {
                t = 73600,
                d = 6,
            },
            {
                t = 73800,
                d = 6,
            },
            {
                t = 74000,
                d = 7,
            },
            {
                t = 74200,
                d = 6,
            },
            {
                t = 74600,
                d = 7,
            },
            {
                t = 74800,
                d = 5,
            },
            {
                t = 75000,
                d = 7,
            },
            {
                t = 75200,
                d = 6,
            },
            {
                t = 75200,
                d = 0,
            },
            {
                t = 75400,
                d = 6,
            },
            {
                t = 75600,
                d = 7,
            },
            {
                t = 75600,
                d = 1,
            },
            {
                t = 75800,
                d = 6,
            },
            {
                t = 76000,
                d = 3,
                l = 100,
            },
            {
                t = 76200,
                d = 7,
            },
            {
                t = 76200,
                d = 1,
            },
            {
                t = 76400,
                d = 5,
            },
            {
                t = 76400,
                d = 0,
                l = 100,
            },
            {
                t = 76600,
                d = 3,
            },
            {
                t = 76800,
                d = 2,
            },
            {
                t = 77200,
                d = 3,
            },
            {
                t = 77600,
                d = 3,
                l = 100,
            },
            {
                t = 77800,
                d = 2,
            },
            {
                t = 78000,
                d = 0,
                l = 100,
            },
            {
                t = 78200,
                d = 3,
            },
            {
                t = 78400,
                d = 1,
            },
            {
                t = 78800,
                d = 1,
            },
            {
                t = 79200,
                d = 0,
                l = 100,
            },
            {
                t = 79400,
                d = 1,
            },
            {
                t = 79600,
                d = 0,
                l = 100,
            },
            {
                t = 79800,
                d = 3,
            },
            {
                t = 80000,
                d = 1,
            },
            {
                t = 80400,
                d = 0,
            },
            {
                t = 80800,
                d = 0,
                l = 100,
            },
            {
                t = 81000,
                d = 2,
            },
            {
                t = 81200,
                d = 3,
                l = 100,
            },
            {
                t = 81400,
                d = 0,
            },
            {
                t = 81600,
                d = 4,
                l = 300,
            },
            {
                t = 81600,
                d = 1,
            },
            {
                t = 82000,
                d = 5,
                l = 300,
            },
            {
                t = 82000,
                d = 0,
            },
            {
                t = 82400,
                d = 7,
                l = 300,
            },
            {
                t = 82400,
                d = 3,
                l = 100,
            },
            {
                t = 82600,
                d = 1,
            },
            {
                t = 82800,
                d = 5,
                l = 300,
            },
            {
                t = 82800,
                d = 0,
                l = 100,
            },
            {
                t = 83000,
                d = 3,
            },
            {
                t = 83200,
                d = 6,
            },
            {
                t = 83400,
                d = 6,
            },
            {
                t = 83600,
                d = 7,
            },
            {
                t = 83800,
                d = 6,
            },
            {
                t = 84200,
                d = 7,
            },
            {
                t = 84400,
                d = 5,
            },
            {
                t = 84600,
                d = 7,
            },
            {
                t = 84800,
                d = 6,
            },
            {
                t = 85000,
                d = 6,
            },
            {
                t = 85200,
                d = 7,
            },
            {
                t = 85400,
                d = 6,
            },
            {
                t = 85800,
                d = 7,
            },
            {
                t = 86000,
                d = 5,
            },
            {
                t = 86400,
                d = 6,
            },
            {
                t = 86600,
                d = 6,
            },
            {
                t = 86800,
                d = 7,
            },
            {
                t = 87000,
                d = 6,
            },
            {
                t = 87400,
                d = 7,
            },
            {
                t = 87600,
                d = 5,
            },
            {
                t = 87800,
                d = 7,
            },
            {
                t = 88000,
                d = 6,
            },
            {
                t = 88000,
                d = 0,
            },
            {
                t = 88200,
                d = 6,
            },
            {
                t = 88400,
                d = 7,
            },
            {
                t = 88400,
                d = 1,
            },
            {
                t = 88600,
                d = 6,
            },
            {
                t = 88800,
                d = 3,
                l = 100,
            },
            {
                t = 89000,
                d = 7,
            },
            {
                t = 89000,
                d = 1,
            },
            {
                t = 89200,
                d = 5,
            },
            {
                t = 89200,
                d = 0,
                l = 100,
            },
            {
                t = 89400,
                d = 3,
            },
            {
                t = 89600,
                d = 5,
                l = 125,
            },
            {
                t = 89600,
                d = 2,
            },
            {
                t = 90000,
                d = 5,
                l = 100,
            },
            {
                t = 90000,
                d = 3,
            },
            {
                t = 90400,
                d = 5,
            },
            {
                t = 90400,
                d = 3,
                l = 100,
            },
            {
                t = 90600,
                d = 2,
            },
            {
                t = 90800,
                d = 0,
                l = 100,
            },
            {
                t = 91000,
                d = 2,
            },
            {
                t = 91200,
                d = 1,
            },
            {
                t = 91600,
                d = 1,
            },
            {
                t = 92000,
                d = 0,
                l = 100,
            },
            {
                t = 92200,
                d = 1,
            },
            {
                t = 92400,
                d = 0,
                l = 100,
            },
            {
                t = 92600,
                d = 3,
            },
            {
                t = 92800,
                d = 1,
            },
            {
                t = 93200,
                d = 0,
            },
            {
                t = 93600,
                d = 0,
                l = 100,
            },
            {
                t = 93800,
                d = 2,
            },
            {
                t = 94000,
                d = 3,
                l = 100,
            },
            {
                t = 94200,
                d = 0,
            },
            {
                t = 94400,
                d = 1,
            },
            {
                t = 94800,
                d = 0,
            },
            {
                t = 95200,
                d = 3,
                l = 100,
            },
            {
                t = 95400,
                d = 1,
            },
            {
                t = 95600,
                d = 0,
                l = 100,
            },
            {
                t = 95800,
                d = 3,
            },
        },
        normal = {
            {
                t = 1200,
                d = 3,
                l = 250,
            },
            {
                t = 2800,
                d = 2,
                l = 250,
            },
            {
                t = 4200,
                d = 1,
            },
            {
                t = 4400,
                d = 0,
            },
            {
                t = 4600,
                d = 1,
            },
            {
                t = 4800,
                d = 3,
            },
            {
                t = 6400,
                d = 4,
            },
            {
                t = 6599,
                d = 5,
            },
            {
                t = 6799,
                d = 7,
            },
            {
                t = 7199,
                d = 7,
            },
            {
                t = 7599,
                d = 6,
            },
            {
                t = 7799,
                d = 7,
            },
            {
                t = 7999,
                d = 5,
            },
            {
                t = 8200,
                d = 7,
            },
            {
                t = 8400,
                d = 7,
            },
            {
                t = 8800,
                d = 6,
            },
            {
                t = 9200,
                d = 4,
            },
            {
                t = 9400,
                d = 7,
            },
            {
                t = 9600,
                d = 3,
                l = 100,
            },
            {
                t = 10000,
                d = 1,
            },
            {
                t = 10200,
                d = 0,
            },
            {
                t = 10400,
                d = 3,
            },
            {
                t = 10800,
                d = 2,
            },
            {
                t = 11200,
                d = 3,
                l = 125,
            },
            {
                t = 11600,
                d = 1,
            },
            {
                t = 11800,
                d = 0,
            },
            {
                t = 12000,
                d = 3,
            },
            {
                t = 12400,
                d = 2,
            },
            {
                t = 12600,
                d = 2,
                l = 125,
            },
            {
                t = 12800,
                d = 6,
            },
            {
                t = 12999,
                d = 7,
            },
            {
                t = 13099,
                d = 5,
            },
            {
                t = 13199,
                d = 4,
            },
            {
                t = 13399,
                d = 4,
            },
            {
                t = 13599,
                d = 6,
            },
            {
                t = 13799,
                d = 7,
            },
            {
                t = 13999,
                d = 5,
            },
            {
                t = 14399,
                d = 5,
            },
            {
                t = 14599,
                d = 4,
            },
            {
                t = 14699,
                d = 5,
            },
            {
                t = 14799,
                d = 7,
            },
            {
                t = 14999,
                d = 7,
            },
            {
                t = 15199,
                d = 4,
            },
            {
                t = 15200,
                d = 3,
            },
            {
                t = 15399,
                d = 4,
            },
            {
                t = 15400,
                d = 2,
            },
            {
                t = 15600,
                d = 6,
                k = "cheer",
            },
            {
                t = 15600,
                d = 0,
            },
            {
                t = 15800,
                d = 2,
            },
            {
                t = 16000,
                d = 3,
            },
            {
                t = 16400,
                d = 0,
            },
            {
                t = 16600,
                d = 0,
                l = 100,
            },
            {
                t = 16800,
                d = 3,
            },
            {
                t = 17200,
                d = 2,
                l = 200,
            },
            {
                t = 17800,
                d = 3,
                l = 100,
            },
            {
                t = 18000,
                d = 2,
                l = 100,
            },
            {
                t = 18400,
                d = 3,
            },
            {
                t = 18600,
                d = 2,
            },
            {
                t = 18800,
                d = 4,
                k = "cheer",
            },
            {
                t = 19000,
                d = 7,
            },
            {
                t = 19200,
                d = 6,
            },
            {
                t = 19400,
                d = 7,
            },
            {
                t = 19500,
                d = 5,
            },
            {
                t = 19600,
                d = 7,
            },
            {
                t = 20000,
                d = 7,
            },
            {
                t = 20300,
                d = 7,
            },
            {
                t = 20600,
                d = 7,
            },
            {
                t = 20800,
                d = 6,
            },
            {
                t = 21000,
                d = 4,
            },
            {
                t = 21100,
                d = 5,
            },
            {
                t = 21200,
                d = 7,
            },
            {
                t = 21600,
                d = 7,
            },
            {
                t = 21900,
                d = 5,
            },
            {
                t = 22000,
                d = 7,
            },
            {
                t = 22200,
                d = 7,
            },
            {
                t = 22400,
                d = 6,
            },
            {
                t = 22600,
                d = 7,
            },
            {
                t = 22700,
                d = 5,
            },
            {
                t = 22800,
                d = 7,
            },
            {
                t = 23200,
                d = 7,
            },
            {
                t = 23500,
                d = 7,
            },
            {
                t = 23800,
                d = 7,
            },
            {
                t = 24000,
                d = 6,
            },
            {
                t = 24200,
                d = 4,
            },
            {
                t = 24300,
                d = 5,
            },
            {
                t = 24400,
                d = 7,
            },
            {
                t = 24800,
                d = 5,
            },
            {
                t = 25200,
                d = 6,
            },
            {
                t = 25400,
                d = 3,
            },
            {
                t = 25400,
                d = 6,
            },
            {
                t = 25600,
                d = 3,
            },
            {
                t = 25700,
                d = 0,
            },
            {
                t = 25800,
                d = 2,
            },
            {
                t = 26000,
                d = 3,
            },
            {
                t = 26200,
                d = 0,
            },
            {
                t = 26400,
                d = 1,
            },
            {
                t = 26700,
                d = 1,
            },
            {
                t = 27000,
                d = 0,
            },
            {
                t = 27200,
                d = 3,
            },
            {
                t = 27300,
                d = 2,
            },
            {
                t = 27400,
                d = 0,
            },
            {
                t = 27600,
                d = 1,
            },
            {
                t = 27800,
                d = 3,
            },
            {
                t = 28000,
                d = 1,
            },
            {
                t = 28400,
                d = 0,
            },
            {
                t = 28800,
                d = 1,
            },
            {
                t = 29200,
                d = 3,
            },
            {
                t = 29400,
                d = 1,
                l = 100,
            },
            {
                t = 29800,
                d = 3,
            },
            {
                t = 30000,
                d = 1,
                l = 125,
            },
            {
                t = 30400,
                d = 1,
                l = 125,
            },
            {
                t = 30600,
                d = 0,
                l = 75,
            },
            {
                t = 31000,
                d = 2,
            },
            {
                t = 31200,
                d = 2,
            },
            {
                t = 31599,
                d = 7,
            },
            {
                t = 31799,
                d = 5,
            },
            {
                t = 31999,
                d = 4,
            },
            {
                t = 32199,
                d = 5,
            },
            {
                t = 32399,
                d = 7,
            },
            {
                t = 32800,
                d = 7,
            },
            {
                t = 33200,
                d = 6,
            },
            {
                t = 33400,
                d = 7,
            },
            {
                t = 33600,
                d = 5,
            },
            {
                t = 33800,
                d = 7,
            },
            {
                t = 34000,
                d = 7,
            },
            {
                t = 34400,
                d = 6,
            },
            {
                t = 34800,
                d = 4,
            },
            {
                t = 35000,
                d = 7,
            },
            {
                t = 35200,
                d = 3,
                l = 100,
            },
            {
                t = 35600,
                d = 1,
            },
            {
                t = 35800,
                d = 0,
            },
            {
                t = 36000,
                d = 3,
            },
            {
                t = 36400,
                d = 2,
            },
            {
                t = 36800,
                d = 3,
                l = 125,
            },
            {
                t = 37200,
                d = 1,
            },
            {
                t = 37400,
                d = 0,
            },
            {
                t = 37600,
                d = 3,
            },
            {
                t = 38000,
                d = 3,
            },
            {
                t = 38200,
                d = 0,
                l = 125,
            },
            {
                t = 38400,
                d = 6,
            },
            {
                t = 38600,
                d = 7,
            },
            {
                t = 38700,
                d = 5,
            },
            {
                t = 38800,
                d = 4,
            },
            {
                t = 39000,
                d = 4,
            },
            {
                t = 39200,
                d = 6,
            },
            {
                t = 39400,
                d = 7,
            },
            {
                t = 39600,
                d = 5,
            },
            {
                t = 40000,
                d = 5,
            },
            {
                t = 40200,
                d = 4,
            },
            {
                t = 40300,
                d = 5,
            },
            {
                t = 40400,
                d = 7,
            },
            {
                t = 40600,
                d = 7,
            },
            {
                t = 40800,
                d = 3,
            },
            {
                t = 40800,
                d = 4,
            },
            {
                t = 41000,
                d = 2,
            },
            {
                t = 41000,
                d = 4,
            },
            {
                t = 41200,
                d = 0,
            },
            {
                t = 41200,
                d = 6,
            },
            {
                t = 41400,
                d = 2,
            },
            {
                t = 41600,
                d = 3,
            },
            {
                t = 42000,
                d = 0,
            },
            {
                t = 42200,
                d = 0,
                l = 100,
            },
            {
                t = 42400,
                d = 3,
            },
            {
                t = 42600,
                d = 0,
            },
            {
                t = 42800,
                d = 2,
                l = 200,
            },
            {
                t = 43400,
                d = 3,
            },
            {
                t = 43600,
                d = 2,
                l = 100,
            },
            {
                t = 44000,
                d = 0,
            },
            {
                t = 44200,
                d = 3,
            },
            {
                t = 44400,
                d = 4,
            },
            {
                t = 44600,
                d = 7,
            },
            {
                t = 44800,
                d = 6,
            },
            {
                t = 45000,
                d = 7,
            },
            {
                t = 45100,
                d = 5,
            },
            {
                t = 45200,
                d = 7,
            },
            {
                t = 45500,
                d = 7,
            },
            {
                t = 45600,
                d = 7,
            },
            {
                t = 45900,
                d = 7,
            },
            {
                t = 46200,
                d = 7,
            },
            {
                t = 46400,
                d = 6,
            },
            {
                t = 46600,
                d = 4,
            },
            {
                t = 46700,
                d = 5,
            },
            {
                t = 46800,
                d = 7,
            },
            {
                t = 47100,
                d = 7,
            },
            {
                t = 47200,
                d = 5,
            },
            {
                t = 47400,
                d = 4,
            },
            {
                t = 47500,
                d = 6,
            },
            {
                t = 47600,
                d = 7,
            },
            {
                t = 47800,
                d = 7,
            },
            {
                t = 47900,
                d = 5,
            },
            {
                t = 48000,
                d = 6,
            },
            {
                t = 48200,
                d = 3,
            },
            {
                t = 48200,
                d = 7,
            },
            {
                t = 48300,
                d = 5,
            },
            {
                t = 48400,
                d = 1,
            },
            {
                t = 48400,
                d = 7,
            },
            {
                t = 48600,
                d = 0,
            },
            {
                t = 48800,
                d = 3,
            },
            {
                t = 48800,
                d = 7,
            },
            {
                t = 49000,
                d = 0,
            },
            {
                t = 49100,
                d = 7,
            },
            {
                t = 49200,
                d = 2,
                l = 175,
            },
            {
                t = 49400,
                d = 7,
            },
            {
                t = 49600,
                d = 6,
            },
            {
                t = 49800,
                d = 4,
            },
            {
                t = 49800,
                d = 2,
            },
            {
                t = 49900,
                d = 5,
            },
            {
                t = 50000,
                d = 1,
            },
            {
                t = 50000,
                d = 7,
            },
            {
                t = 50200,
                d = 3,
            },
            {
                t = 50400,
                d = 7,
            },
            {
                t = 50400,
                d = 0,
            },
            {
                t = 50600,
                d = 3,
            },
            {
                t = 50700,
                d = 7,
            },
            {
                t = 50800,
                d = 1,
            },
            {
                t = 51000,
                d = 0,
                l = 100,
            },
            {
                t = 51000,
                d = 7,
            },
            {
                t = 51200,
                d = 3,
            },
            {
                t = 51300,
                d = 1,
            },
            {
                t = 51400,
                d = 2,
            },
            {
                t = 51600,
                d = 3,
            },
            {
                t = 51800,
                d = 0,
            },
            {
                t = 52000,
                d = 3,
            },
            {
                t = 52300,
                d = 3,
            },
            {
                t = 52600,
                d = 0,
            },
            {
                t = 52800,
                d = 3,
            },
            {
                t = 52900,
                d = 2,
            },
            {
                t = 53000,
                d = 0,
            },
            {
                t = 53200,
                d = 1,
            },
            {
                t = 53400,
                d = 0,
            },
            {
                t = 53600,
                d = 2,
            },
            {
                t = 54000,
                d = 1,
            },
            {
                t = 54400,
                d = 1,
            },
            {
                t = 54800,
                d = 3,
            },
            {
                t = 55000,
                d = 1,
                l = 100,
            },
            {
                t = 55400,
                d = 3,
            },
            {
                t = 55600,
                d = 1,
                l = 125,
            },
            {
                t = 56000,
                d = 1,
                l = 125,
            },
            {
                t = 56200,
                d = 0,
                l = 75,
            },
            {
                t = 56600,
                d = 2,
            },
            {
                t = 56800,
                d = 2,
            },
            {
                t = 57200,
                d = 0,
                l = 225,
            },
            {
                t = 57550,
                d = 4,
            },
            {
                t = 57600,
                d = 6,
                l = 300,
            },
            {
                t = 58000,
                d = 7,
                l = 300,
            },
            {
                t = 58400,
                d = 5,
                l = 150,
            },
            {
                t = 58650,
                d = 7,
            },
            {
                t = 58700,
                d = 4,
            },
            {
                t = 58800,
                d = 6,
                l = 300,
            },
            {
                t = 59200,
                d = 6,
                l = 100,
            },
            {
                t = 59400,
                d = 7,
                l = 100,
            },
            {
                t = 59600,
                d = 4,
                l = 200,
            },
            {
                t = 59850,
                d = 6,
            },
            {
                t = 59900,
                d = 4,
            },
            {
                t = 60000,
                d = 5,
                l = 300,
            },
            {
                t = 60400,
                d = 6,
                l = 300,
            },
            {
                t = 60800,
                d = 5,
            },
            {
                t = 61200,
                d = 5,
            },
            {
                t = 61400,
                d = 7,
            },
            {
                t = 61800,
                d = 7,
            },
            {
                t = 62000,
                d = 4,
            },
            {
                t = 62150,
                d = 3,
                l = 125,
            },
            {
                t = 62200,
                d = 7,
            },
            {
                t = 62400,
                d = 5,
            },
            {
                t = 62400,
                d = 1,
            },
            {
                t = 62800,
                d = 1,
            },
            {
                t = 62800,
                d = 5,
            },
            {
                t = 63000,
                d = 0,
                l = 125,
            },
            {
                t = 63000,
                d = 7,
            },
            {
                t = 63400,
                d = 3,
                l = 125,
            },
            {
                t = 63400,
                d = 7,
            },
            {
                t = 63500,
                d = 7,
            },
            {
                t = 63600,
                d = 4,
            },
            {
                t = 63600,
                d = 1,
            },
            {
                t = 63800,
                d = 7,
            },
            {
                t = 63800,
                d = 3,
            },
            {
                t = 64000,
                d = 1,
            },
            {
                t = 64200,
                d = 2,
            },
            {
                t = 64600,
                d = 0,
            },
            {
                t = 64800,
                d = 2,
            },
            {
                t = 65200,
                d = 3,
                l = 150,
            },
            {
                t = 65200,
                d = 1,
            },
            {
                t = 65600,
                d = 0,
            },
            {
                t = 65800,
                d = 3,
            },
            {
                t = 66200,
                d = 3,
            },
            {
                t = 66400,
                d = 1,
            },
            {
                t = 66800,
                d = 2,
            },
            {
                t = 66800,
                d = 0,
            },
            {
                t = 67200,
                d = 1,
            },
            {
                t = 67400,
                d = 3,
            },
            {
                t = 67800,
                d = 0,
            },
            {
                t = 68000,
                d = 3,
            },
            {
                t = 68000,
                d = 2,
            },
            {
                t = 68400,
                d = 1,
                l = 200,
            },
            {
                t = 68800,
                d = 0,
            },
            {
                t = 69000,
                d = 2,
            },
            {
                t = 69400,
                d = 3,
            },
            {
                t = 69600,
                d = 2,
            },
            {
                t = 69800,
                d = 0,
            },
            {
                t = 70000,
                d = 3,
                l = 216.666666666652,
            },
            {
                t = 70400,
                d = 6,
            },
            {
                t = 70600,
                d = 6,
            },
            {
                t = 70800,
                d = 7,
            },
            {
                t = 71000,
                d = 6,
            },
            {
                t = 71400,
                d = 7,
            },
            {
                t = 71600,
                d = 5,
            },
            {
                t = 71800,
                d = 7,
            },
            {
                t = 72000,
                d = 6,
            },
            {
                t = 72200,
                d = 6,
            },
            {
                t = 72400,
                d = 7,
            },
            {
                t = 72600,
                d = 6,
            },
            {
                t = 73000,
                d = 7,
            },
            {
                t = 73200,
                d = 5,
            },
            {
                t = 73600,
                d = 6,
            },
            {
                t = 73800,
                d = 6,
            },
            {
                t = 74000,
                d = 7,
            },
            {
                t = 74200,
                d = 6,
            },
            {
                t = 74600,
                d = 7,
            },
            {
                t = 74800,
                d = 5,
            },
            {
                t = 75000,
                d = 7,
            },
            {
                t = 75200,
                d = 6,
            },
            {
                t = 75200,
                d = 2,
            },
            {
                t = 75400,
                d = 6,
            },
            {
                t = 75400,
                d = 3,
            },
            {
                t = 75600,
                d = 1,
            },
            {
                t = 75600,
                d = 7,
            },
            {
                t = 75800,
                d = 6,
            },
            {
                t = 75800,
                d = 3,
            },
            {
                t = 76000,
                d = 0,
            },
            {
                t = 76200,
                d = 7,
            },
            {
                t = 76200,
                d = 2,
            },
            {
                t = 76400,
                d = 5,
            },
            {
                t = 76400,
                d = 1,
                l = 100,
            },
            {
                t = 76600,
                d = 3,
            },
            {
                t = 76800,
                d = 0,
            },
            {
                t = 77000,
                d = 2,
            },
            {
                t = 77200,
                d = 1,
            },
            {
                t = 77400,
                d = 3,
            },
            {
                t = 77600,
                d = 2,
            },
            {
                t = 77800,
                d = 3,
            },
            {
                t = 78000,
                d = 0,
                l = 100,
            },
            {
                t = 78200,
                d = 3,
            },
            {
                t = 78400,
                d = 2,
            },
            {
                t = 78600,
                d = 0,
            },
            {
                t = 78800,
                d = 1,
            },
            {
                t = 79000,
                d = 3,
            },
            {
                t = 79200,
                d = 0,
                l = 100,
            },
            {
                t = 79400,
                d = 1,
            },
            {
                t = 79600,
                d = 0,
                l = 100,
            },
            {
                t = 79800,
                d = 3,
            },
            {
                t = 80000,
                d = 1,
            },
            {
                t = 80200,
                d = 2,
            },
            {
                t = 80400,
                d = 0,
            },
            {
                t = 80600,
                d = 3,
            },
            {
                t = 80800,
                d = 2,
            },
            {
                t = 81000,
                d = 3,
            },
            {
                t = 81200,
                d = 0,
            },
            {
                t = 81400,
                d = 3,
            },
            {
                t = 81600,
                d = 4,
                l = 300,
            },
            {
                t = 81600,
                d = 0,
            },
            {
                t = 81800,
                d = 1,
            },
            {
                t = 82000,
                d = 5,
                l = 300,
            },
            {
                t = 82000,
                d = 3,
            },
            {
                t = 82200,
                d = 0,
            },
            {
                t = 82400,
                d = 7,
                l = 300,
            },
            {
                t = 82400,
                d = 2,
                l = 100,
            },
            {
                t = 82600,
                d = 0,
            },
            {
                t = 82800,
                d = 5,
                l = 300,
            },
            {
                t = 82800,
                d = 3,
            },
            {
                t = 83000,
                d = 1,
            },
            {
                t = 83200,
                d = 6,
            },
            {
                t = 83400,
                d = 6,
            },
            {
                t = 83600,
                d = 7,
            },
            {
                t = 83800,
                d = 6,
            },
            {
                t = 84200,
                d = 7,
            },
            {
                t = 84400,
                d = 5,
            },
            {
                t = 84600,
                d = 7,
            },
            {
                t = 84800,
                d = 6,
            },
            {
                t = 85000,
                d = 6,
            },
            {
                t = 85200,
                d = 7,
            },
            {
                t = 85400,
                d = 6,
            },
            {
                t = 85800,
                d = 7,
            },
            {
                t = 86000,
                d = 5,
            },
            {
                t = 86400,
                d = 6,
            },
            {
                t = 86600,
                d = 6,
            },
            {
                t = 86800,
                d = 7,
            },
            {
                t = 87000,
                d = 6,
            },
            {
                t = 87400,
                d = 7,
            },
            {
                t = 87600,
                d = 5,
            },
            {
                t = 87800,
                d = 7,
            },
            {
                t = 88000,
                d = 6,
            },
            {
                t = 88000,
                d = 2,
            },
            {
                t = 88200,
                d = 6,
            },
            {
                t = 88200,
                d = 3,
            },
            {
                t = 88400,
                d = 7,
            },
            {
                t = 88400,
                d = 1,
            },
            {
                t = 88600,
                d = 6,
            },
            {
                t = 88600,
                d = 3,
            },
            {
                t = 88800,
                d = 0,
            },
            {
                t = 89000,
                d = 7,
            },
            {
                t = 89000,
                d = 2,
            },
            {
                t = 89200,
                d = 5,
            },
            {
                t = 89200,
                d = 1,
                l = 100,
            },
            {
                t = 89400,
                d = 3,
            },
            {
                t = 89600,
                d = 5,
                l = 125,
            },
            {
                t = 89600,
                d = 0,
            },
            {
                t = 89800,
                d = 2,
            },
            {
                t = 90000,
                d = 5,
                l = 100,
            },
            {
                t = 90000,
                d = 1,
            },
            {
                t = 90200,
                d = 3,
            },
            {
                t = 90400,
                d = 5,
            },
            {
                t = 90400,
                d = 2,
            },
            {
                t = 90600,
                d = 3,
            },
            {
                t = 90800,
                d = 0,
                l = 100,
            },
            {
                t = 91000,
                d = 3,
            },
            {
                t = 91200,
                d = 2,
            },
            {
                t = 91400,
                d = 0,
            },
            {
                t = 91600,
                d = 1,
            },
            {
                t = 91800,
                d = 3,
            },
            {
                t = 92000,
                d = 0,
                l = 100,
            },
            {
                t = 92200,
                d = 1,
            },
            {
                t = 92400,
                d = 0,
                l = 100,
            },
            {
                t = 92600,
                d = 3,
            },
            {
                t = 92800,
                d = 1,
            },
            {
                t = 93000,
                d = 2,
            },
            {
                t = 93200,
                d = 0,
            },
            {
                t = 93400,
                d = 3,
            },
            {
                t = 93600,
                d = 1,
            },
            {
                t = 93800,
                d = 3,
            },
            {
                t = 94000,
                d = 0,
            },
            {
                t = 94200,
                d = 3,
            },
            {
                t = 94400,
                d = 0,
            },
            {
                t = 94600,
                d = 1,
            },
            {
                t = 94800,
                d = 3,
            },
            {
                t = 95000,
                d = 0,
            },
            {
                t = 95200,
                d = 2,
                l = 100,
            },
            {
                t = 95400,
                d = 0,
            },
            {
                t = 95600,
                d = 3,
            },
            {
                t = 95800,
                d = 1,
            },
        },
        hard = {
            {
                t = 1200,
                d = 3,
                l = 250,
            },
            {
                t = 2800,
                d = 2,
                l = 250,
            },
            {
                t = 4200,
                d = 1,
            },
            {
                t = 4400,
                d = 0,
            },
            {
                t = 4600,
                d = 1,
            },
            {
                t = 4800,
                d = 3,
            },
            {
                t = 6400,
                d = 4,
            },
            {
                t = 6599,
                d = 5,
            },
            {
                t = 6799,
                d = 7,
            },
            {
                t = 7199,
                d = 7,
            },
            {
                t = 7599,
                d = 6,
            },
            {
                t = 7799,
                d = 7,
            },
            {
                t = 7999,
                d = 5,
            },
            {
                t = 8200,
                d = 7,
            },
            {
                t = 8400,
                d = 7,
            },
            {
                t = 8800,
                d = 6,
            },
            {
                t = 9200,
                d = 4,
            },
            {
                t = 9400,
                d = 7,
            },
            {
                t = 9600,
                d = 1,
                l = 300,
            },
            {
                t = 10000,
                d = 0,
            },
            {
                t = 10200,
                d = 3,
            },
            {
                t = 10400,
                d = 1,
            },
            {
                t = 10400,
                d = 0,
            },
            {
                t = 10600,
                d = 2,
            },
            {
                t = 10800,
                d = 0,
            },
            {
                t = 11000,
                d = 3,
            },
            {
                t = 11200,
                d = 1,
                l = 300,
            },
            {
                t = 11600,
                d = 3,
            },
            {
                t = 11800,
                d = 2,
            },
            {
                t = 12000,
                d = 0,
            },
            {
                t = 12400,
                d = 3,
            },
            {
                t = 12600,
                d = 0,
                l = 250,
            },
            {
                t = 12800,
                d = 6,
            },
            {
                t = 12999,
                d = 7,
            },
            {
                t = 13099,
                d = 5,
            },
            {
                t = 13199,
                d = 4,
            },
            {
                t = 13399,
                d = 4,
            },
            {
                t = 13599,
                d = 6,
            },
            {
                t = 13799,
                d = 7,
            },
            {
                t = 13999,
                d = 5,
            },
            {
                t = 14399,
                d = 5,
            },
            {
                t = 14599,
                d = 4,
            },
            {
                t = 14699,
                d = 5,
            },
            {
                t = 14799,
                d = 7,
            },
            {
                t = 14999,
                d = 7,
            },
            {
                t = 15199,
                d = 4,
            },
            {
                t = 15200,
                d = 3,
            },
            {
                t = 15399,
                d = 4,
            },
            {
                t = 15400,
                d = 2,
            },
            {
                t = 15600,
                d = 0,
            },
            {
                t = 15600,
                d = 6,
            },
            {
                t = 15800,
                d = 2,
            },
            {
                t = 16000,
                d = 3,
            },
            {
                t = 16200,
                d = 1,
            },
            {
                t = 16400,
                d = 0,
            },
            {
                t = 16600,
                d = 2,
            },
            {
                t = 16800,
                d = 3,
            },
            {
                t = 16800,
                d = 1,
            },
            {
                t = 17000,
                d = 0,
            },
            {
                t = 17200,
                d = 1,
                l = 250,
            },
            {
                t = 17800,
                d = 2,
            },
            {
                t = 18000,
                d = 0,
            },
            {
                t = 18400,
                d = 1,
            },
            {
                t = 18600,
                d = 3,
            },
            {
                t = 18800,
                d = 4,
                k = "cheer",
            },
            {
                t = 19000,
                d = 7,
            },
            {
                t = 19200,
                d = 6,
            },
            {
                t = 19400,
                d = 7,
            },
            {
                t = 19500,
                d = 5,
            },
            {
                t = 19600,
                d = 7,
            },
            {
                t = 20000,
                d = 7,
            },
            {
                t = 20300,
                d = 7,
            },
            {
                t = 20600,
                d = 7,
            },
            {
                t = 20800,
                d = 6,
            },
            {
                t = 21000,
                d = 4,
            },
            {
                t = 21100,
                d = 5,
            },
            {
                t = 21200,
                d = 7,
            },
            {
                t = 21600,
                d = 7,
            },
            {
                t = 21900,
                d = 5,
            },
            {
                t = 22000,
                d = 7,
            },
            {
                t = 22200,
                d = 7,
            },
            {
                t = 22400,
                d = 6,
            },
            {
                t = 22600,
                d = 7,
            },
            {
                t = 22700,
                d = 5,
            },
            {
                t = 22800,
                d = 7,
            },
            {
                t = 23200,
                d = 7,
            },
            {
                t = 23500,
                d = 7,
            },
            {
                t = 23800,
                d = 7,
            },
            {
                t = 24000,
                d = 6,
            },
            {
                t = 24200,
                d = 4,
            },
            {
                t = 24300,
                d = 5,
            },
            {
                t = 24400,
                d = 7,
            },
            {
                t = 24800,
                d = 5,
            },
            {
                t = 25200,
                d = 6,
            },
            {
                t = 25400,
                d = 6,
            },
            {
                t = 25400,
                d = 1,
            },
            {
                t = 25500,
                d = 3,
            },
            {
                t = 25600,
                d = 1,
            },
            {
                t = 25700,
                d = 2,
            },
            {
                t = 25800,
                d = 0,
            },
            {
                t = 26000,
                d = 3,
            },
            {
                t = 26200,
                d = 1,
            },
            {
                t = 26400,
                d = 0,
            },
            {
                t = 26400,
                d = 2,
            },
            {
                t = 26700,
                d = 1,
            },
            {
                t = 26700,
                d = 3,
            },
            {
                t = 27000,
                d = 2,
            },
            {
                t = 27100,
                d = 0,
            },
            {
                t = 27200,
                d = 3,
            },
            {
                t = 27300,
                d = 2,
            },
            {
                t = 27400,
                d = 0,
            },
            {
                t = 27600,
                d = 1,
            },
            {
                t = 27800,
                d = 0,
            },
            {
                t = 28000,
                d = 2,
            },
            {
                t = 28000,
                d = 3,
            },
            {
                t = 28400,
                d = 0,
            },
            {
                t = 28400,
                d = 1,
            },
            {
                t = 28800,
                d = 1,
            },
            {
                t = 28800,
                d = 3,
            },
            {
                t = 29200,
                d = 2,
            },
            {
                t = 29400,
                d = 0,
            },
            {
                t = 29800,
                d = 1,
            },
            {
                t = 30000,
                d = 3,
            },
            {
                t = 30400,
                d = 1,
            },
            {
                t = 30600,
                d = 0,
            },
            {
                t = 31000,
                d = 0,
            },
            {
                t = 31200,
                d = 3,
                l = 250,
            },
            {
                t = 31599,
                d = 7,
            },
            {
                t = 31799,
                d = 5,
            },
            {
                t = 31999,
                d = 4,
            },
            {
                t = 32199,
                d = 5,
            },
            {
                t = 32399,
                d = 7,
            },
            {
                t = 32800,
                d = 7,
            },
            {
                t = 33200,
                d = 6,
            },
            {
                t = 33400,
                d = 7,
            },
            {
                t = 33600,
                d = 5,
            },
            {
                t = 33800,
                d = 7,
            },
            {
                t = 34000,
                d = 7,
            },
            {
                t = 34400,
                d = 6,
            },
            {
                t = 34800,
                d = 4,
            },
            {
                t = 35000,
                d = 7,
            },
            {
                t = 35200,
                d = 1,
                l = 300,
            },
            {
                t = 35600,
                d = 0,
            },
            {
                t = 35800,
                d = 3,
            },
            {
                t = 36000,
                d = 1,
            },
            {
                t = 36000,
                d = 0,
            },
            {
                t = 36200,
                d = 2,
            },
            {
                t = 36400,
                d = 0,
            },
            {
                t = 36600,
                d = 3,
            },
            {
                t = 36800,
                d = 1,
                l = 300,
            },
            {
                t = 37200,
                d = 3,
            },
            {
                t = 37400,
                d = 2,
            },
            {
                t = 37600,
                d = 0,
            },
            {
                t = 38000,
                d = 1,
            },
            {
                t = 38200,
                d = 3,
                l = 250,
            },
            {
                t = 38400,
                d = 6,
            },
            {
                t = 38600,
                d = 7,
            },
            {
                t = 38700,
                d = 5,
            },
            {
                t = 38800,
                d = 4,
            },
            {
                t = 39000,
                d = 4,
            },
            {
                t = 39200,
                d = 6,
            },
            {
                t = 39400,
                d = 7,
            },
            {
                t = 39600,
                d = 5,
            },
            {
                t = 40000,
                d = 5,
            },
            {
                t = 40200,
                d = 4,
            },
            {
                t = 40300,
                d = 5,
            },
            {
                t = 40400,
                d = 7,
            },
            {
                t = 40600,
                d = 7,
            },
            {
                t = 40800,
                d = 4,
            },
            {
                t = 40800,
                d = 3,
            },
            {
                t = 41000,
                d = 4,
            },
            {
                t = 41000,
                d = 0,
            },
            {
                t = 41200,
                d = 2,
            },
            {
                t = 41200,
                d = 6,
            },
            {
                t = 41400,
                d = 3,
            },
            {
                t = 41600,
                d = 0,
            },
            {
                t = 41800,
                d = 1,
            },
            {
                t = 42000,
                d = 3,
            },
            {
                t = 42200,
                d = 0,
            },
            {
                t = 42400,
                d = 3,
            },
            {
                t = 42400,
                d = 2,
            },
            {
                t = 42600,
                d = 0,
            },
            {
                t = 42800,
                d = 1,
            },
            {
                t = 43400,
                d = 1,
            },
            {
                t = 43600,
                d = 3,
            },
            {
                t = 44000,
                d = 1,
            },
            {
                t = 44200,
                d = 0,
            },
            {
                t = 44400,
                d = 4,
            },
            {
                t = 44600,
                d = 7,
            },
            {
                t = 44800,
                d = 6,
            },
            {
                t = 45000,
                d = 7,
            },
            {
                t = 45100,
                d = 5,
            },
            {
                t = 45200,
                d = 7,
            },
            {
                t = 45500,
                d = 7,
            },
            {
                t = 45600,
                d = 7,
            },
            {
                t = 45900,
                d = 7,
            },
            {
                t = 46200,
                d = 7,
            },
            {
                t = 46400,
                d = 6,
            },
            {
                t = 46600,
                d = 4,
            },
            {
                t = 46700,
                d = 5,
            },
            {
                t = 46800,
                d = 7,
            },
            {
                t = 47100,
                d = 7,
            },
            {
                t = 47200,
                d = 5,
            },
            {
                t = 47400,
                d = 4,
            },
            {
                t = 47500,
                d = 6,
            },
            {
                t = 47600,
                d = 7,
            },
            {
                t = 47800,
                d = 7,
            },
            {
                t = 47900,
                d = 5,
            },
            {
                t = 48000,
                d = 6,
            },
            {
                t = 48200,
                d = 7,
            },
            {
                t = 48200,
                d = 0,
            },
            {
                t = 48300,
                d = 5,
            },
            {
                t = 48400,
                d = 7,
            },
            {
                t = 48400,
                d = 1,
            },
            {
                t = 48600,
                d = 3,
            },
            {
                t = 48800,
                d = 7,
            },
            {
                t = 48800,
                d = 1,
            },
            {
                t = 49000,
                d = 2,
            },
            {
                t = 49100,
                d = 7,
            },
            {
                t = 49200,
                d = 1,
            },
            {
                t = 49250,
                d = 0,
                l = 250,
            },
            {
                t = 49400,
                d = 7,
            },
            {
                t = 49600,
                d = 6,
            },
            {
                t = 49800,
                d = 4,
            },
            {
                t = 49800,
                d = 2,
            },
            {
                t = 49900,
                d = 5,
            },
            {
                t = 50000,
                d = 7,
            },
            {
                t = 50000,
                d = 1,
            },
            {
                t = 50200,
                d = 3,
            },
            {
                t = 50300,
                d = 0,
            },
            {
                t = 50400,
                d = 7,
            },
            {
                t = 50400,
                d = 1,
                l = 150,
            },
            {
                t = 50600,
                d = 3,
                l = 150,
            },
            {
                t = 50700,
                d = 7,
            },
            {
                t = 50800,
                d = 1,
            },
            {
                t = 51000,
                d = 0,
            },
            {
                t = 51000,
                d = 7,
            },
            {
                t = 51200,
                d = 1,
            },
            {
                t = 51300,
                d = 2,
            },
            {
                t = 51400,
                d = 0,
            },
            {
                t = 51600,
                d = 3,
            },
            {
                t = 51800,
                d = 1,
            },
            {
                t = 52000,
                d = 0,
            },
            {
                t = 52000,
                d = 2,
            },
            {
                t = 52300,
                d = 1,
            },
            {
                t = 52300,
                d = 3,
            },
            {
                t = 52600,
                d = 2,
            },
            {
                t = 52700,
                d = 0,
            },
            {
                t = 52800,
                d = 3,
            },
            {
                t = 52900,
                d = 2,
            },
            {
                t = 53000,
                d = 0,
            },
            {
                t = 53200,
                d = 1,
            },
            {
                t = 53400,
                d = 0,
            },
            {
                t = 53600,
                d = 2,
            },
            {
                t = 53600,
                d = 3,
            },
            {
                t = 54000,
                d = 0,
            },
            {
                t = 54000,
                d = 1,
            },
            {
                t = 54400,
                d = 1,
            },
            {
                t = 54400,
                d = 3,
            },
            {
                t = 54800,
                d = 2,
            },
            {
                t = 55000,
                d = 0,
            },
            {
                t = 55400,
                d = 1,
            },
            {
                t = 55600,
                d = 3,
            },
            {
                t = 56000,
                d = 2,
            },
            {
                t = 56200,
                d = 0,
            },
            {
                t = 56600,
                d = 1,
            },
            {
                t = 56800,
                d = 3,
                l = 250,
            },
            {
                t = 57200,
                d = 0,
                l = 250,
            },
            {
                t = 57600,
                d = 4,
            },
            {
                t = 57650,
                d = 6,
                l = 250,
            },
            {
                t = 58000,
                d = 7,
                l = 300,
            },
            {
                t = 58400,
                d = 5,
                l = 150,
            },
            {
                t = 58600,
                d = 6,
            },
            {
                t = 58700,
                d = 4,
            },
            {
                t = 58800,
                d = 5,
                l = 300,
            },
            {
                t = 59200,
                d = 6,
                l = 100,
            },
            {
                t = 59400,
                d = 7,
                l = 100,
            },
            {
                t = 59600,
                d = 4,
                l = 150,
            },
            {
                t = 59800,
                d = 6,
            },
            {
                t = 59900,
                d = 7,
            },
            {
                t = 60000,
                d = 5,
                l = 300,
            },
            {
                t = 60400,
                d = 6,
                l = 300,
            },
            {
                t = 60800,
                d = 5,
            },
            {
                t = 61200,
                d = 5,
            },
            {
                t = 61400,
                d = 7,
            },
            {
                t = 61800,
                d = 7,
            },
            {
                t = 62000,
                d = 4,
            },
            {
                t = 62150,
                d = 1,
            },
            {
                t = 62200,
                d = 7,
            },
            {
                t = 62400,
                d = 5,
            },
            {
                t = 62400,
                d = 0,
            },
            {
                t = 62800,
                d = 5,
            },
            {
                t = 62800,
                d = 1,
            },
            {
                t = 63000,
                d = 7,
            },
            {
                t = 63000,
                d = 3,
            },
            {
                t = 63400,
                d = 7,
            },
            {
                t = 63400,
                d = 0,
            },
            {
                t = 63500,
                d = 7,
            },
            {
                t = 63600,
                d = 4,
            },
            {
                t = 63600,
                d = 1,
            },
            {
                t = 63800,
                d = 7,
            },
            {
                t = 63800,
                d = 3,
            },
            {
                t = 64000,
                d = 1,
            },
            {
                t = 64200,
                d = 0,
            },
            {
                t = 64200,
                d = 2,
            },
            {
                t = 64600,
                d = 1,
            },
            {
                t = 64800,
                d = 3,
            },
            {
                t = 64800,
                d = 2,
            },
            {
                t = 65200,
                d = 1,
            },
            {
                t = 65200,
                d = 3,
            },
            {
                t = 65600,
                d = 0,
            },
            {
                t = 65800,
                d = 3,
            },
            {
                t = 66200,
                d = 2,
            },
            {
                t = 66400,
                d = 1,
            },
            {
                t = 66400,
                d = 0,
            },
            {
                t = 66800,
                d = 2,
            },
            {
                t = 66800,
                d = 0,
            },
            {
                t = 67200,
                d = 1,
            },
            {
                t = 67400,
                d = 3,
            },
            {
                t = 67800,
                d = 0,
            },
            {
                t = 68000,
                d = 3,
            },
            {
                t = 68000,
                d = 2,
            },
            {
                t = 68400,
                d = 1,
            },
            {
                t = 68400,
                d = 2,
            },
            {
                t = 68800,
                d = 0,
            },
            {
                t = 69000,
                d = 3,
            },
            {
                t = 69400,
                d = 1,
            },
            {
                t = 69600,
                d = 2,
            },
            {
                t = 69800,
                d = 0,
            },
            {
                t = 70000,
                d = 3,
                l = 250,
            },
            {
                t = 70400,
                d = 6,
            },
            {
                t = 70600,
                d = 6,
            },
            {
                t = 70800,
                d = 7,
            },
            {
                t = 71000,
                d = 6,
            },
            {
                t = 71400,
                d = 7,
            },
            {
                t = 71600,
                d = 5,
            },
            {
                t = 71800,
                d = 7,
            },
            {
                t = 72000,
                d = 6,
            },
            {
                t = 72200,
                d = 6,
            },
            {
                t = 72400,
                d = 7,
            },
            {
                t = 72600,
                d = 6,
            },
            {
                t = 73000,
                d = 7,
            },
            {
                t = 73200,
                d = 5,
            },
            {
                t = 73600,
                d = 6,
            },
            {
                t = 73800,
                d = 6,
            },
            {
                t = 74000,
                d = 7,
            },
            {
                t = 74200,
                d = 6,
            },
            {
                t = 74600,
                d = 7,
            },
            {
                t = 74800,
                d = 5,
            },
            {
                t = 75000,
                d = 7,
            },
            {
                t = 75200,
                d = 6,
            },
            {
                t = 75200,
                d = 2,
            },
            {
                t = 75400,
                d = 6,
            },
            {
                t = 75400,
                d = 3,
            },
            {
                t = 75600,
                d = 7,
            },
            {
                t = 75600,
                d = 1,
            },
            {
                t = 75800,
                d = 6,
            },
            {
                t = 75800,
                d = 3,
            },
            {
                t = 76000,
                d = 0,
            },
            {
                t = 76200,
                d = 7,
            },
            {
                t = 76200,
                d = 2,
            },
            {
                t = 76400,
                d = 5,
            },
            {
                t = 76400,
                d = 1,
            },
            {
                t = 76600,
                d = 3,
            },
            {
                t = 76800,
                d = 1,
            },
            {
                t = 76800,
                d = 0,
            },
            {
                t = 77000,
                d = 2,
            },
            {
                t = 77200,
                d = 0,
            },
            {
                t = 77400,
                d = 3,
            },
            {
                t = 77600,
                d = 1,
            },
            {
                t = 77600,
                d = 2,
            },
            {
                t = 77800,
                d = 0,
            },
            {
                t = 78000,
                d = 2,
            },
            {
                t = 78000,
                d = 3,
            },
            {
                t = 78200,
                d = 1,
            },
            {
                t = 78400,
                d = 0,
            },
            {
                t = 78400,
                d = 2,
            },
            {
                t = 78600,
                d = 1,
            },
            {
                t = 78800,
                d = 3,
            },
            {
                t = 79000,
                d = 2,
            },
            {
                t = 79200,
                d = 1,
            },
            {
                t = 79200,
                d = 0,
            },
            {
                t = 79400,
                d = 3,
            },
            {
                t = 79600,
                d = 2,
            },
            {
                t = 79800,
                d = 0,
            },
            {
                t = 80000,
                d = 1,
            },
            {
                t = 80000,
                d = 3,
            },
            {
                t = 80200,
                d = 2,
            },
            {
                t = 80400,
                d = 3,
            },
            {
                t = 80600,
                d = 2,
            },
            {
                t = 80800,
                d = 1,
            },
            {
                t = 80800,
                d = 0,
            },
            {
                t = 81000,
                d = 3,
            },
            {
                t = 81200,
                d = 2,
            },
            {
                t = 81200,
                d = 1,
            },
            {
                t = 81400,
                d = 0,
            },
            {
                t = 81600,
                d = 4,
                l = 300,
            },
            {
                t = 81600,
                d = 1,
            },
            {
                t = 81600,
                d = 3,
            },
            {
                t = 81800,
                d = 2,
            },
            {
                t = 82000,
                d = 5,
                l = 300,
            },
            {
                t = 82000,
                d = 0,
            },
            {
                t = 82200,
                d = 3,
            },
            {
                t = 82400,
                d = 7,
                l = 300,
            },
            {
                t = 82400,
                d = 1,
            },
            {
                t = 82400,
                d = 0,
            },
            {
                t = 82600,
                d = 2,
            },
            {
                t = 82800,
                d = 5,
                l = 300,
            },
            {
                t = 82800,
                d = 1,
            },
            {
                t = 82800,
                d = 3,
            },
            {
                t = 83000,
                d = 0,
            },
            {
                t = 83200,
                d = 6,
            },
            {
                t = 83400,
                d = 6,
            },
            {
                t = 83600,
                d = 7,
            },
            {
                t = 83800,
                d = 6,
            },
            {
                t = 84200,
                d = 7,
            },
            {
                t = 84400,
                d = 5,
            },
            {
                t = 84600,
                d = 7,
            },
            {
                t = 84800,
                d = 6,
            },
            {
                t = 85000,
                d = 6,
            },
            {
                t = 85200,
                d = 7,
            },
            {
                t = 85400,
                d = 6,
            },
            {
                t = 85800,
                d = 7,
            },
            {
                t = 86000,
                d = 5,
            },
            {
                t = 86400,
                d = 6,
            },
            {
                t = 86600,
                d = 6,
            },
            {
                t = 86800,
                d = 7,
            },
            {
                t = 87000,
                d = 6,
            },
            {
                t = 87400,
                d = 7,
            },
            {
                t = 87600,
                d = 5,
            },
            {
                t = 87800,
                d = 7,
            },
            {
                t = 88000,
                d = 6,
            },
            {
                t = 88000,
                d = 3,
            },
            {
                t = 88200,
                d = 6,
            },
            {
                t = 88200,
                d = 1,
            },
            {
                t = 88400,
                d = 7,
            },
            {
                t = 88400,
                d = 0,
            },
            {
                t = 88600,
                d = 6,
            },
            {
                t = 88600,
                d = 3,
            },
            {
                t = 88800,
                d = 1,
            },
            {
                t = 89000,
                d = 7,
            },
            {
                t = 89000,
                d = 0,
            },
            {
                t = 89200,
                d = 5,
            },
            {
                t = 89200,
                d = 2,
            },
            {
                t = 89400,
                d = 3,
            },
            {
                t = 89600,
                d = 5,
                l = 125,
            },
            {
                t = 89600,
                d = 1,
            },
            {
                t = 89600,
                d = 0,
            },
            {
                t = 89800,
                d = 2,
            },
            {
                t = 90000,
                d = 5,
                l = 100,
            },
            {
                t = 90000,
                d = 0,
            },
            {
                t = 90200,
                d = 3,
            },
            {
                t = 90400,
                d = 5,
            },
            {
                t = 90400,
                d = 1,
            },
            {
                t = 90400,
                d = 2,
            },
            {
                t = 90600,
                d = 0,
            },
            {
                t = 90800,
                d = 2,
            },
            {
                t = 90800,
                d = 3,
            },
            {
                t = 91000,
                d = 1,
            },
            {
                t = 91200,
                d = 0,
            },
            {
                t = 91200,
                d = 2,
            },
            {
                t = 91400,
                d = 1,
            },
            {
                t = 91600,
                d = 3,
            },
            {
                t = 91800,
                d = 2,
            },
            {
                t = 92000,
                d = 1,
            },
            {
                t = 92000,
                d = 0,
            },
            {
                t = 92200,
                d = 3,
            },
            {
                t = 92400,
                d = 2,
            },
            {
                t = 92600,
                d = 0,
            },
            {
                t = 92800,
                d = 1,
            },
            {
                t = 92800,
                d = 3,
            },
            {
                t = 93000,
                d = 2,
            },
            {
                t = 93200,
                d = 3,
            },
            {
                t = 93400,
                d = 2,
            },
            {
                t = 93600,
                d = 1,
            },
            {
                t = 93600,
                d = 0,
            },
            {
                t = 93800,
                d = 3,
            },
            {
                t = 94000,
                d = 2,
            },
            {
                t = 94000,
                d = 1,
            },
            {
                t = 94200,
                d = 0,
            },
            {
                t = 94400,
                d = 1,
            },
            {
                t = 94400,
                d = 3,
            },
            {
                t = 94600,
                d = 2,
            },
            {
                t = 94800,
                d = 0,
            },
            {
                t = 95000,
                d = 3,
            },
            {
                t = 95200,
                d = 1,
            },
            {
                t = 95200,
                d = 0,
            },
            {
                t = 95400,
                d = 2,
            },
            {
                t = 95600,
                d = 1,
            },
            {
                t = 95600,
                d = 3,
            },
            {
                t = 95800,
                d = 0,
            },
        },
    },
    generatedBy = "Friday Night Funkin' - v0.6.2 (rewrite/master:02dc353:MODIFIED) PROTOTYPE",
}