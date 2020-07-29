package wgorchestrator

import (
	"net"
	"time"

	"github.com/inverse-inc/packetfence/go/sharedutils"
	"github.com/jinzhu/gorm"
)

// TODO: have this configurable and potentially support multiple ranges
var startingIP = sharedutils.IP2Int(net.ParseIP("192.168.69.1"))
var netmask = 24

type RemoteClient struct {
	ID         uint `gorm:"primary_key"`
	CreatedAt  time.Time
	UpdatedAt  time.Time
	TenantId   uint
	PublicKey  string
	BypassRole uint
}

func GetOrCreateRemoteClient(db *gorm.DB, publicKey string) (*RemoteClient, error) {
	rc := RemoteClient{}
	db.Where("public_key = ?", publicKey).First(&rc)
	if rc.PublicKey != publicKey {
		rc.PublicKey = publicKey
		err := db.Create(&rc).Error
		return &rc, err
	} else {
		return &rc, nil
	}
}

func (rc *RemoteClient) IPAddress() net.IP {
	//TODO: change this so that we don't get out of bounds too easily since IDs in a cluster jump by the size of the cluster
	return sharedutils.Int2IP(startingIP + uint32(rc.ID))
}

func (rc *RemoteClient) Netmask() int {
	return netmask
}

func (rc *RemoteClient) AllowedPeers(db *gorm.DB) []string {
	keys := []string{}
	db.Model(&RemoteClient{}).Where("public_key != ?", rc.PublicKey).Pluck("public_key", &keys)
	return keys
}
