<template>
  <div class="app-container">
    <!--filter-->
    <div class="filter">
      <el-input
        v-model="filter.keyword"
        prefix-icon="el-icon-search"
        :placeholder="$t('Search')"
        class="filter-search"
        @change="onSearch"
      />
      <div class="right">
        <el-button
          type="success"
          icon="el-icon-refresh"
          class="refresh"
          @click="onRefresh"
        >
          {{ $t('Refresh') }}
        </el-button>
      </div>
    </div>

    <!--table list-->
    <el-table
      :data="filteredTableData"
      class="table"
      :header-cell-style="{background:'rgb(48, 65, 86)',color:'white'}"
      border
    >
      <template v-for="col in columns">
        <el-table-column
          v-if="col.name === 'spider_name'"
          :key="col.name"
          :label="$t(col.label)"
          :sortable="col.sortable"
          align="center"
          :width="col.width"
        >
          <template slot-scope="scope">
            <a class="a-tag" href="javascript:" @click="onClickSpider(scope.row)">{{ scope.row[col.name] }}</a>
          </template>
        </el-table-column>
        <el-table-column
          v-else-if="col.name === 'node_id'"
          :key="col.name"
          :label="$t(col.label)"
          :sortable="col.sortable"
          align="center"
          :width="col.width"
        >
          <template slot-scope="scope">
            <a class="a-tag" href="javascript:" @click="onClickNode(scope.row)">{{ scope.row[col.name] }}</a>
          </template>
        </el-table-column>
        <el-table-column
          v-else
          :key="col.name"
          :property="col.name"
          :label="$t(col.label)"
          :sortable="col.sortable"
          align="center"
          :width="col.width"
        />
      </template>
      <el-table-column :label="$t('Action')" align="center" width="160">
        <template slot-scope="scope">
          <el-tooltip :content="$t('View')" placement="top">
            <el-button type="primary" icon="el-icon-search" size="mini" @click="onView(scope.row)" />
          </el-tooltip>
        </template>
      </el-table-column>
    </el-table>
    <div class="pagination">
      <el-pagination
        :current-page.sync="pagination.pageNum"
        :page-sizes="[10, 20, 50, 100]"
        :page-size.sync="pagination.pageSize"
        layout="sizes, prev, pager, next"
        :total="deployList.length"
        @current-change="onPageChange"
        @size-change="onPageChange"
      />
    </div>
  </div>
</template>

<script>
  import {
    mapState
  } from 'vuex'

  export default {
    name: 'DeployList',
    data() {
      return {
        pagination: {
          pageNum: 0,
          pageSize: 10
        },
        filter: {
          keyword: ''
        },
        // tableData,
        columns: [
          // { name: 'version', label: 'Version', width: '180' },
          // { name: 'ip', label: 'IP', width: '160' },
          // { name: 'port', label: 'Port', width: '80' },
          { name: 'finish_ts', label: 'Time', width: '180' },
          { name: 'spider_name', label: 'Spider', width: '180', sortable: true },
          { name: 'node_id', label: 'Node', width: 'auto' }
        ],
        nodeFormRules: {
          name: [{ required: true, message: 'Required Field', trigger: 'change' }]
        }
      }
    },
    computed: {
      ...mapState('deploy', [
        'deployList',
        'deployForm'
      ]),
      filteredTableData() {
        return this.deployList.filter(d => {
          if (!this.filter.keyword) return true
          for (let i = 0; i < this.columns.length; i++) {
            const colName = this.columns[i].name
            if (d[colName] && d[colName].toLowerCase().indexOf(this.filter.keyword.toLowerCase()) > -1) {
              return true
            }
          }
          return false
        })
          .filter((d, index) => {
            // pagination
            const { pageNum, pageSize } = this.pagination
            return (pageSize * (pageNum - 1) <= index) && (index < pageSize * pageNum)
          })
      }
    },
    created() {
      this.$store.dispatch('deploy/getDeployList')
    },
    methods: {
      onSearch(value) {
        console.log(value)
      },
      onRefresh() {
        this.$store.dispatch('deploy/getDeployList')
        this.$st.sendEv('部署', '刷新')
      },
      onView(row) {
        this.$router.push(`/deploys/${row._id}`)
      },
      onClickSpider(row) {
        this.$router.push(`/spiders/${row.spider_id}`)
      },
      onClickNode(row) {
        this.$router.push(`/nodes/${row.node_id}`)
      },
      onPageChange() {
        this.$store.dispatch('deploy/getDeployList')
      }
    }
  }
</script>

<style scoped lang="scss">
  .filter {
    display: flex;
    justify-content: space-between;

    .filter-search {
      width: 240px;
    }

    .add {
    }
  }

  .table {
    margin-top: 20px;
    border-radius: 5px;
  }

  .delete-confirm {
    background-color: red;
  }

  .el-table .el-button {
    padding: 7px;
  }

  .el-table .a-tag {
    text-decoration: underline;
  }
</style>
