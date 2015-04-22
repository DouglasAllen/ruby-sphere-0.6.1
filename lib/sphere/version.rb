#
# version.rb: defines version and copyright notice
#
# $Id: version.rb,v 1.50 2007/03/01 05:25:55 tomono Exp $
#
# Copyright:: Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>
# License::   GPL
#

module Sphere
  # release version/patch level of this package
  VERSION = '0.6.1'

  # package name
  NAME = 'ruby-sphere'

  # package name and version
  PKGNAME = "#{NAME}-#{VERSION}"

  # copyright notices for this package
  LICENSE = <<'_END'
Permission is granted for use, copying, modification, distribution, and
distribution of modified versions of this work under the terms of GPL
version 2 or later.
_END

  COPYRIGHT = 'Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>'

  COPYRIGHT_LONG = <<'_END'
ruby-sphere: calculates apparent positions of stars

Copyright (C) 2004 Daigo Tomono <dtomono at freeshell.org>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
_END

end
