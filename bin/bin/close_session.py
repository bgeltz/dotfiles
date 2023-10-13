import sys
from geopmdpy import pio
from dasbus.connection import SystemMessageBus

def main():
    bus = SystemMessageBus()
    proxy = bus.get_proxy('io.github.geopm', '/io/github/geopm')
    proxy.PlatformCloseSessionAdmin(int(sys.argv[1]))
    bus.disconnect()

if __name__ == '__main__':
    main()
