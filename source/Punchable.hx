package;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.effects.FlxFlicker;
import flixel.util.FlxSort;

class Punchable extends FlxSprite
{
    public var grpHurtboxes:FlxTypedSpriteGroup<Hitbox>;
    public var grpHitboxes:FlxTypedSpriteGroup<Hitbox>;
    public var curAnimation:Int = 0;
    public var blocking:Bool = false;
    public var justHurt:Bool = false;
    public var justHurtframecount:Int = 6;
    private var _hurtinCount:Int = 0;

    public var actualHealth:Float = 1;
    public var invincibleFrames:Float = 0;
    public var recoilTime:Float = 0;

    public var hurtboxes:Array<Dynamic> = 
    [
        [
            [-30, -15, 60, 30]
        ]
    ];

    private var ogDrag:FlxPoint;

    public var hitboxes:Array<Dynamic> =
    [
        [
            [30, -5, 20, 20]
        ]
    ];

    public function new(X: Float, Y: Float)
    {
        super(X, Y);
        makeGraphic(100, 100);
       
        offset.y = 85;
        var daOffsetY:Float = height - offset.y;
        height = daOffsetY;

        grpHurtboxes = new FlxTypedSpriteGroup<Hitbox>();
        grpHurtboxes.visible = false;
        //add(grpHurtboxes);

        grpHitboxes = new FlxTypedSpriteGroup<Hitbox>();
        grpHitboxes.visible = false;
        //add(grpHitboxes);

        drag.x = 300;

        generateHitboxes();
    }

    public function generateHitboxes():Void
    {
        // Start fresh
        grpHitboxes.forEach(function(spr:Hitbox){grpHitboxes.remove(spr, true); });
        grpHurtboxes.forEach(function(spr:Hitbox){grpHurtboxes.remove(spr, true); });

        for (i in hurtboxes)
        {
            var dumb:Array<Dynamic> = i;
            for (b in dumb)
            {
                trace(b);
 
                var testObj:Hitbox = new Hitbox(b[0], b[1]);
                testObj.makeGraphic(Std.int(b[2]), Std.int(b[3]));
                testObj.offsetShit = new FlxRect(b[0], b[1], b[2], b[3]);
                testObj.alpha = 0.5;
                grpHurtboxes.add(testObj);
                testObj.color = FlxColor.GREEN;
            }
        }

        for (i in hitboxes)
        {
            var dumb:Array<Dynamic> = i;
            for (b in dumb)
            {
                var testObj:Hitbox = new Hitbox(b[0], b[1]);
                testObj.makeGraphic(Std.int(b[2]), Std.int(b[3]));
                testObj.offsetShit = new FlxRect(b[0], b[1], b[2], b[3]);
                testObj.alpha = 0.5;
                grpHitboxes.add(testObj);
                testObj.color = FlxColor.RED;
            }
        }
    }

    public function getHurt(dmg:Float, ?fromPos:FlxSprite):Void
    {
        if (invincibleFrames <= 0)
        {
            if (!blocking)
            {
                justHurt = true;
                actualHealth -= dmg;
                invincibleFrames = 0.1;
                recoilTime = 0.1;

                if (fromPos != null)
                {
                    if (fromPos.x < x)
                        velocity.x = 200 + (fromPos.velocity.x * 1.5);
                    if (fromPos.x > x)
                        velocity.x = -200 + (fromPos.velocity.x * 1.5); 
                }
            }
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (invincibleFrames > 0)
        {
            invincibleFrames -= FlxG.elapsed;
        }

        if (recoilTime > 0)
            recoilTime -= FlxG.elapsed;

            
        if (actualHealth <= 0)
            getKilled();

        grpHurtboxes.forEach(function(spr:Hitbox)
        {
            setSpritePos(spr);
        });

        grpHitboxes.forEach(function(spr:Hitbox)
        {
            setSpritePos(spr);

        });

        if (justHurt)
        {
            color = FlxColor.RED;

            _hurtinCount += 1;
            if (_hurtinCount >= justHurtframecount)
            {
                _hurtinCount = 0;
                justHurt = false;
            }
        }    
        else
            color = FlxColor.WHITE;

        // testObj.setPosition(daSprite.x + hurtboxes[0][0][0], daSprite.y + hurtboxes[0][0][1]);

    }

    private function getKilled():Void
    {
        grpHitboxes.kill();
        grpHurtboxes.kill();

    }

    private function setSpritePos(spr:Hitbox):Void
    {
        /* 
        if (daSprite.facing == FlxObject.RIGHT)
            spr.setPosition(daSprite.getMidpoint().x + (spr.offsetShit.x), daSprite.y + spr.offsetShit.y);
        if (daSprite.facing == FlxObject.LEFT)
            spr.setPosition(daSprite.getMidpoint().x - (spr.offsetShit.x) - spr.width, daSprite.y + spr.offsetShit.y);
        */
        if (facing == FlxObject.RIGHT)
            spr.setPosition(getMidpoint().x + (spr.offsetShit.x), y + spr.offsetShit.y);
        if (facing == FlxObject.LEFT)
            spr.setPosition(getMidpoint().x - (spr.offsetShit.x) - spr.width, y + spr.offsetShit.y);
    }

    public static inline function bySprite(Order:Int, Obj1:Punchable, Obj2:Punchable):Int
	{
		// return FlxSort.byValues(Order, Obj1.daSprite.y, Obj2.daSprite.y);
        return FlxSort.byValues(Order, Obj1.y, Obj2.y);
	}
}