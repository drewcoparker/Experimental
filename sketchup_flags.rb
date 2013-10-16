#! /usr/bin/env ruby


class SketchupFlags

  def maccmdflags(cmd, flag1, flag2, flag3)

  @cmd = cmd
  @flag1 = flag1
  @flag2 = flag2
  @flag3 = flag3

  end

  def wincmdflags(cmd, flag1, flag2, flag3)

  @cmd = cmd
  @flag1 = flag1
  @flag2 = flag2
  @flag3 = flag3

  end

  def startexe(cmd)

    @cmd = cmd
    pid = Process.spawn(cmd)
    supid = 1 + pid.to_int
    Process.waitpid(supid)

  end

end
